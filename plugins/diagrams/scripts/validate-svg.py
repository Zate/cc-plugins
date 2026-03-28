#!/usr/bin/env python3
"""
SVG Diagram Validator
Checks for common layout issues: arrow-through-box, label overlaps,
insufficient clearance, parallel arrow collision, container padding.

Usage: python3 validate-svg.py <file.svg>

Exit codes:
  0 = no issues found
  1 = issues found (printed to stdout)
  2 = error (bad file, parse failure)

No external dependencies -- uses only Python stdlib.
"""

import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from typing import List, Tuple, Optional

# Clearance thresholds (pixels)
ARROW_BOX_CLEARANCE = 20
PARALLEL_ARROW_MIN_SEP = 30
LABEL_LINE_CLEARANCE = 8
CONTAINER_PADDING = 15


@dataclass
class Box:
    """A rectangle element (node, container, boundary)."""
    id: str
    x: float
    y: float
    w: float
    h: float
    is_container: bool = False  # dashed stroke = container/boundary
    label: str = ""

    @property
    def x2(self): return self.x + self.w
    @property
    def y2(self): return self.y + self.h
    @property
    def cx(self): return self.x + self.w / 2
    @property
    def cy(self): return self.y + self.h / 2

    def contains_point(self, px, py, margin=0):
        return (self.x - margin <= px <= self.x2 + margin and
                self.y - margin <= py <= self.y2 + margin)

    def intersects(self, other, margin=0):
        return not (self.x2 + margin < other.x - margin or
                    other.x2 + margin < self.x - margin or
                    self.y2 + margin < other.y - margin or
                    other.y2 + margin < self.y - margin)

    def contains_box(self, other, padding=0):
        return (self.x + padding <= other.x and
                self.y + padding <= other.y and
                self.x2 - padding >= other.x2 and
                self.y2 - padding >= other.y2)


@dataclass
class Line:
    """A line element (arrow/connector)."""
    id: str
    x1: float
    y1: float
    x2: float
    y2: float
    has_marker: bool = False  # has arrowhead

    @property
    def is_horizontal(self): return abs(self.y2 - self.y1) < 3
    @property
    def is_vertical(self): return abs(self.x2 - self.x1) < 3
    @property
    def length(self):
        return ((self.x2-self.x1)**2 + (self.y2-self.y1)**2) ** 0.5


@dataclass
class Label:
    """A text element."""
    id: str
    x: float
    y: float
    text: str
    font_size: float = 12
    anchor: str = "start"

    @property
    def approx_width(self):
        return len(self.text) * self.font_size * 0.55

    @property
    def approx_height(self):
        return self.font_size * 1.2

    def get_bbox(self):
        w = self.approx_width
        h = self.approx_height
        if self.anchor == "middle":
            return (self.x - w/2, self.y - h, w, h)
        elif self.anchor == "end":
            return (self.x - w, self.y - h, w, h)
        return (self.x, self.y - h, w, h)


def line_intersects_box(line: Line, box: Box, margin: float = 0) -> bool:
    """Check if a line segment passes through a box (with margin)."""
    bx1 = box.x - margin
    by1 = box.y - margin
    bx2 = box.x2 + margin
    by2 = box.y2 + margin

    # Quick check: if both endpoints are on the same side, no intersection
    lx1, ly1, lx2, ly2 = line.x1, line.y1, line.x2, line.y2

    # Check if either endpoint is inside the box
    if bx1 <= lx1 <= bx2 and by1 <= ly1 <= by2:
        return True
    if bx1 <= lx2 <= bx2 and by1 <= ly2 <= by2:
        return True

    # For axis-aligned lines (most SVG diagram arrows), simplified check
    if line.is_vertical:
        x = lx1
        if bx1 <= x <= bx2:
            min_y = min(ly1, ly2)
            max_y = max(ly1, ly2)
            if min_y <= by2 and max_y >= by1:
                return True
        return False

    if line.is_horizontal:
        y = ly1
        if by1 <= y <= by2:
            min_x = min(lx1, lx2)
            max_x = max(lx1, lx2)
            if min_x <= bx2 and max_x >= bx1:
                return True
        return False

    # General case: check line-rect intersection using parametric form
    dx = lx2 - lx1
    dy = ly2 - ly1
    edges = [
        (bx1, by1, bx2, by1),  # top
        (bx1, by2, bx2, by2),  # bottom
        (bx1, by1, bx1, by2),  # left
        (bx2, by1, bx2, by2),  # right
    ]
    for ex1, ey1, ex2, ey2 in edges:
        if segments_intersect(lx1, ly1, lx2, ly2, ex1, ey1, ex2, ey2):
            return True
    return False


def segments_intersect(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2) -> bool:
    """Check if two line segments intersect."""
    def cross(ox, oy, ax, ay, bx, by):
        return (ax - ox) * (by - oy) - (ay - oy) * (bx - ox)

    d1 = cross(bx1, by1, bx2, by2, ax1, ay1)
    d2 = cross(bx1, by1, bx2, by2, ax2, ay2)
    d3 = cross(ax1, ay1, ax2, ay2, bx1, by1)
    d4 = cross(ax1, ay1, ax2, ay2, bx2, by2)

    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
       ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
        return True
    return False


def lines_are_parallel_and_close(a: Line, b: Line, threshold: float) -> bool:
    """Check if two lines are roughly parallel and closer than threshold."""
    # Both horizontal
    if a.is_horizontal and b.is_horizontal:
        if abs(a.y1 - b.y1) < threshold:
            # Check x-overlap
            a_min_x = min(a.x1, a.x2)
            a_max_x = max(a.x1, a.x2)
            b_min_x = min(b.x1, b.x2)
            b_max_x = max(b.x1, b.x2)
            if a_min_x < b_max_x and b_min_x < a_max_x:
                return True

    # Both vertical
    if a.is_vertical and b.is_vertical:
        if abs(a.x1 - b.x1) < threshold:
            a_min_y = min(a.y1, a.y2)
            a_max_y = max(a.y1, a.y2)
            b_min_y = min(b.y1, b.y2)
            b_max_y = max(b.y1, b.y2)
            if a_min_y < b_max_y and b_min_y < a_max_y:
                return True

    return False


def label_overlaps_line(label: Label, line: Line, clearance: float) -> bool:
    """Check if a label's bounding box overlaps or is too close to a line."""
    lx, ly, lw, lh = label.get_bbox()
    lx2 = lx + lw
    ly2 = ly + lh

    if line.is_horizontal:
        y = line.y1
        min_x = min(line.x1, line.x2)
        max_x = max(line.x1, line.x2)
        if lx < max_x and lx2 > min_x:
            if abs(y - ly) < clearance or abs(y - ly2) < clearance or (ly <= y <= ly2):
                return True

    if line.is_vertical:
        x = line.x1
        min_y = min(line.y1, line.y2)
        max_y = max(line.y1, line.y2)
        if ly < max_y and ly2 > min_y:
            if abs(x - lx) < clearance or abs(x - lx2) < clearance or (lx <= x <= lx2):
                return True

    return False


def label_overlaps_box(label: Label, box: Box) -> bool:
    """Check if a label's bounding box overlaps a box it's not inside of."""
    lx, ly, lw, lh = label.get_bbox()
    label_box = Box(id="label", x=lx, y=ly, w=lw, h=lh)
    return label_box.intersects(box)


def parse_float(val: Optional[str], default: float = 0) -> float:
    if val is None:
        return default
    try:
        return float(val.replace("px", "").strip())
    except ValueError:
        return default


def parse_svg(filepath: str):
    """Parse SVG file and extract boxes, lines, and labels."""
    try:
        tree = ET.parse(filepath)
    except ET.ParseError as e:
        print(f"ERROR: Failed to parse SVG: {e}", file=sys.stderr)
        sys.exit(2)

    root = tree.getroot()
    ns = {"svg": "http://www.w3.org/2000/svg"}

    boxes: List[Box] = []
    lines: List[Line] = []
    labels: List[Label] = []

    elem_counter = 0

    def get_id(elem):
        nonlocal elem_counter
        elem_counter += 1
        eid = elem.get("id", "")
        return eid if eid else f"elem-{elem_counter}"

    # Find all rects
    for rect in root.iter("{http://www.w3.org/2000/svg}rect"):
        x = parse_float(rect.get("x"))
        y = parse_float(rect.get("y"))
        w = parse_float(rect.get("width"))
        h = parse_float(rect.get("height"))

        if w < 10 or h < 10:
            continue  # skip tiny rects (decorative)

        # Check if it's the background rect
        vb = root.get("viewBox", "")
        if vb:
            parts = vb.split()
            if len(parts) == 4:
                vb_w, vb_h = float(parts[2]), float(parts[3])
                if abs(w - vb_w) < 5 and abs(h - vb_h) < 5:
                    continue  # skip background rect

        is_container = False
        stroke_da = rect.get("stroke-dasharray", "")
        if stroke_da:
            is_container = True
        fill = rect.get("fill", "")
        if "none" == fill.lower():
            is_container = True

        boxes.append(Box(
            id=get_id(rect),
            x=x, y=y, w=w, h=h,
            is_container=is_container
        ))

    # Find all lines
    for line_elem in root.iter("{http://www.w3.org/2000/svg}line"):
        x1 = parse_float(line_elem.get("x1"))
        y1 = parse_float(line_elem.get("y1"))
        x2 = parse_float(line_elem.get("x2"))
        y2 = parse_float(line_elem.get("y2"))

        has_marker = bool(line_elem.get("marker-end", ""))

        lines.append(Line(
            id=get_id(line_elem),
            x1=x1, y1=y1, x2=x2, y2=y2,
            has_marker=has_marker
        ))

    # Find all text
    for text_elem in root.iter("{http://www.w3.org/2000/svg}text"):
        x = parse_float(text_elem.get("x"))
        y = parse_float(text_elem.get("y"))
        text = text_elem.text or ""
        # Include tspans
        for tspan in text_elem:
            if tspan.text:
                text += tspan.text
        text = text.strip()
        if not text:
            continue

        font_size = parse_float(text_elem.get("font-size"), 12)
        anchor = text_elem.get("text-anchor", "start")

        labels.append(Label(
            id=get_id(text_elem),
            x=x, y=y,
            text=text,
            font_size=font_size,
            anchor=anchor
        ))

    return boxes, lines, labels


def validate(boxes, lines, labels):
    """Run all validation checks. Returns list of issue strings."""
    issues = []

    # Separate node boxes from container boxes
    node_boxes = [b for b in boxes if not b.is_container]
    containers = [b for b in boxes if b.is_container]

    # --- Check 1: Arrow lines passing through unrelated boxes ---
    for line in lines:
        if line.length < 15:
            continue  # skip very short lines (connectors between adjacent elements)
        for box in node_boxes:
            # Skip if line starts or ends inside/at the box (it's connected)
            starts_at = box.contains_point(line.x1, line.y1, margin=5)
            ends_at = box.contains_point(line.x2, line.y2, margin=5)
            if starts_at or ends_at:
                continue

            if line_intersects_box(line, box):
                issues.append(
                    f"OVERLAP: Line {line.id} ({line.x1:.0f},{line.y1:.0f} -> "
                    f"{line.x2:.0f},{line.y2:.0f}) passes through box {box.id} "
                    f"at ({box.x:.0f},{box.y:.0f} {box.w:.0f}x{box.h:.0f})"
                )

    # --- Check 2: Parallel arrows too close ---
    for i, a in enumerate(lines):
        if a.length < 30:
            continue
        for b in lines[i+1:]:
            if b.length < 30:
                continue
            if lines_are_parallel_and_close(a, b, PARALLEL_ARROW_MIN_SEP):
                if a.is_horizontal and b.is_horizontal:
                    sep = abs(a.y1 - b.y1)
                    issues.append(
                        f"PARALLEL: Horizontal lines {a.id} (y={a.y1:.0f}) and "
                        f"{b.id} (y={b.y1:.0f}) are only {sep:.0f}px apart "
                        f"(min: {PARALLEL_ARROW_MIN_SEP}px)"
                    )
                elif a.is_vertical and b.is_vertical:
                    sep = abs(a.x1 - b.x1)
                    issues.append(
                        f"PARALLEL: Vertical lines {a.id} (x={a.x1:.0f}) and "
                        f"{b.id} (x={b.x1:.0f}) are only {sep:.0f}px apart "
                        f"(min: {PARALLEL_ARROW_MIN_SEP}px)"
                    )

    # --- Check 3: Labels overlapping lines ---
    for label in labels:
        if len(label.text) < 2:
            continue  # skip single chars (step numbers etc.)
        for line in lines:
            if line.length < 15:
                continue
            if label_overlaps_line(label, line, LABEL_LINE_CLEARANCE):
                issues.append(
                    f"LABEL-LINE: Label \"{label.text[:30]}\" at ({label.x:.0f},"
                    f"{label.y:.0f}) overlaps line {line.id}"
                )

    # --- Check 4: Labels overlapping unrelated boxes ---
    for label in labels:
        if len(label.text) < 3:
            continue
        lx, ly, lw, lh = label.get_bbox()
        for box in node_boxes:
            # Skip if label is inside the box (it's the box's own label)
            if box.contains_point(label.x, label.y, margin=2):
                continue
            if label_overlaps_box(label, box):
                issues.append(
                    f"LABEL-BOX: Label \"{label.text[:30]}\" at ({label.x:.0f},"
                    f"{label.y:.0f}) overlaps box {box.id} at "
                    f"({box.x:.0f},{box.y:.0f})"
                )

    # --- Check 5: Container boundary padding ---
    for container in containers:
        enclosed = [b for b in node_boxes if container.contains_box(b, padding=0)]
        for box in enclosed:
            if not container.contains_box(box, padding=CONTAINER_PADDING):
                # Find which side is too close
                gaps = {
                    "left": box.x - container.x,
                    "top": box.y - container.y,
                    "right": container.x2 - box.x2,
                    "bottom": container.y2 - box.y2,
                }
                tight = {k: v for k, v in gaps.items() if v < CONTAINER_PADDING}
                sides = ", ".join(f"{k}={v:.0f}px" for k, v in tight.items())
                issues.append(
                    f"PADDING: Box {box.id} at ({box.x:.0f},{box.y:.0f}) is too "
                    f"close to container {container.id} boundary ({sides}, "
                    f"min: {CONTAINER_PADDING}px)"
                )

    return issues


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file.svg>", file=sys.stderr)
        sys.exit(2)

    filepath = sys.argv[1]
    boxes, lines, labels = parse_svg(filepath)

    print(f"Parsed: {len(boxes)} boxes, {len(lines)} lines, {len(labels)} labels")

    issues = validate(boxes, lines, labels)

    if not issues:
        print("OK: No layout issues detected.")
        sys.exit(0)

    print(f"\nFound {len(issues)} issue(s):\n")
    for i, issue in enumerate(issues, 1):
        print(f"  {i}. {issue}")

    # Summary by type
    types = {}
    for issue in issues:
        t = issue.split(":")[0]
        types[t] = types.get(t, 0) + 1
    print(f"\nSummary: {', '.join(f'{v} {k.lower()}' for k, v in types.items())}")

    sys.exit(1)


if __name__ == "__main__":
    main()
