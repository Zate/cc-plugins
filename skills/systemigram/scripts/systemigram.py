#!/usr/bin/env python3
"""systemigram.py — geometry, validation, and SVG-snippet generation for systemigrams.

Single-file stdlib-only CLI. No external dependencies.
Usage: python systemigram.py <subcommand> [args] [--agent-help [cmd]]
"""
import argparse
import math
import re
import sys
import xml.etree.ElementTree as ET

# ---------------------------------------------------------------------------
# Style constants (visual identity — do not parameterise)
# ---------------------------------------------------------------------------

DOMAIN = {
    'green':  {'stroke': '#00875A', 'text': '#00644E', 'grad': 'gGreen',  'arrow': 'arrGreen'},
    'blue':   {'stroke': '#0747A6', 'text': '#0747A6', 'grad': 'gBlue',   'arrow': 'arrBlue'},
    'purple': {'stroke': '#5243AA', 'text': '#403294', 'grad': 'gPurple', 'arrow': 'arrPurple'},
    'red':    {'stroke': '#BF2600', 'text': '#9F1F00', 'grad': 'gRed',    'arrow': 'arrRed'},
    'gray':   {'stroke': '#42526E', 'text': '#172B4D', 'grad': 'gGray',   'arrow': 'arrGray'},
    'amber':  {'stroke': '#974F00', 'text': '#974F00', 'grad': 'gAmber',  'arrow': 'arrAmber'},
}

CATEGORY = {
    'spine':   {'width': 2.4, 'dash': None,  'bend': 0.12, 'force_color': None},
    'gov':     {'width': 2.0, 'dash': None,  'bend': 0.18, 'force_color': 'purple'},
    'supp':    {'width': 1.8, 'dash': None,  'bend': 0.18, 'force_color': None},
    'loop':    {'width': 2.6, 'dash': None,  'bend': 0.40, 'force_color': 'amber'},
    'prevent': {'width': 1.8, 'dash': '6,3', 'bend': 0.22, 'force_color': 'red'},
    'anchors': {'width': 2.0, 'dash': '6,3', 'bend': 0.18, 'force_color': 'purple'},
}

TIER = {
    'hero':      {'title_size': 16, 'title_weight': 700, 'stroke_width': 2.6},
    'primary':   {'title_size': 15, 'title_weight': 700, 'stroke_width': 2.0},
    'secondary': {'title_size': 14, 'title_weight': 700, 'stroke_width': 1.6},
}

# ---------------------------------------------------------------------------
# Agent-help content (tier 1 = index, tier 2 = per-command detail)
# ---------------------------------------------------------------------------

AGENT_HELP_TIER1 = """\
systemigram.py — SVG geometry + snippet CLI for systemigrams
Commands:
  build     Read YAML DSL → auto-layout + bearing anchors → emit SVG  ★ start here
  init      Write boilerplate SVG (gradients, markers, shadow filter)
  node      Emit <g> ellipse + text snippet for a node
  edge      Compute boundary pts, Bezier ctrl, label pos; emit path+rect+text
  arrow     Emit path given start, end, desired apex (solves for ctrl pt)
  loop      Multi-segment cubic Bezier edge through 1-2 via points
  spine     Parse verb-noun chain; print triples + verb-tense warnings
  validate  Parse SVG; run 9 cardinal-rule checks; print pass/fail report
  geom      Pure-math helpers: bearing, anchors, gap, boundary, ctrl, midpoint

Usage: python systemigram.py <cmd> --agent-help   # tier-2 detail
       python systemigram.py <cmd> [args]          # run command

Domains: green blue purple red gray amber
Categories: spine gov supp loop prevent anchors
Tiers: hero primary secondary
"""

# ---------------------------------------------------------------------------
# Geometry math (pure functions)
# ---------------------------------------------------------------------------

def edge_pt(cx, cy, rx, ry, px, py, pad=10):
    """Ellipse boundary point in direction of (px,py), offset by pad outward."""
    dx, dy = px - cx, py - cy
    if dx == 0 and dy == 0:
        return cx, cy
    t = 1.0 / math.sqrt((dx / rx) ** 2 + (dy / ry) ** 2)
    bx, by = cx + t * dx, cy + t * dy
    L = math.hypot(dx, dy)
    bx += pad * dx / L
    by += pad * dy / L
    return round(bx, 1), round(by, 1)


def quad_ctrl(x1, y1, x2, y2, bend):
    """Quadratic Bezier control point. bend > 0 = right of chord, < 0 = left."""
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    dx, dy = x2 - x1, y2 - y1
    L = math.hypot(dx, dy)
    if L == 0:
        return round(mx, 1), round(my, 1)
    px, py = -dy / L, dx / L  # perpendicular unit vector (right of chord)
    return round(mx + px * L * bend, 1), round(my + py * L * bend, 1)


def quad_mid(x1, y1, cxv, cyv, x2, y2):
    """Quadratic Bezier midpoint at t=0.5."""
    return 0.25 * (x1 + x2) + 0.5 * cxv, 0.25 * (y1 + y2) + 0.5 * cyv


def cubic_mid(x1, y1, c1x, c1y, c2x, c2y, x2, y2):
    """Cubic Bezier midpoint at t=0.5."""
    mx = 0.125 * x1 + 0.375 * c1x + 0.375 * c2x + 0.125 * x2
    my = 0.125 * y1 + 0.375 * c1y + 0.375 * c2y + 0.125 * y2
    return mx, my


def in_ellipse(px, py, cx, cy, rx, ry, pad=0):
    """Return True if (px,py) is strictly inside the ellipse (with optional pad)."""
    return ((px - cx) / (rx + pad)) ** 2 + ((py - cy) / (ry + pad)) ** 2 < 1.0


# Cardinal directions as unit-vector angles (name → (dx, dy) unit vector)
# N = up (SVG y increases downward, so N is dy=-1)
_ANCHOR_DIRS = {
    'N':  ( 0.0, -1.0),
    'NE': ( math.sqrt(2)/2, -math.sqrt(2)/2),
    'E':  ( 1.0,  0.0),
    'SE': ( math.sqrt(2)/2,  math.sqrt(2)/2),
    'S':  ( 0.0,  1.0),
    'SW': (-math.sqrt(2)/2,  math.sqrt(2)/2),
    'W':  (-1.0,  0.0),
    'NW': (-math.sqrt(2)/2, -math.sqrt(2)/2),
}
_ANCHOR_ORDER = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']


def ellipse_anchors(cx, cy, rx, ry, pad=0):
    """Return dict of 8 named anchor points on the ellipse boundary (+ optional outward pad).

    For an ellipse cx,cy,rx,ry the parametric point in direction (dx,dy) is:
        t = 1 / sqrt((dx/rx)^2 + (dy/ry)^2)
        bx, by = cx + t*dx, cy + t*dy
    Then offset outward by pad pixels along the same direction.

    Returns: {'N': (x,y), 'NE': (x,y), 'E': (x,y), ..., 'NW': (x,y)}
    """
    pts = {}
    for name, (dx, dy) in _ANCHOR_DIRS.items():
        t = 1.0 / math.sqrt((dx / rx) ** 2 + (dy / ry) ** 2)
        bx = cx + t * dx
        by = cy + t * dy
        if pad:
            bx += pad * dx
            by += pad * dy
        pts[name] = (round(bx, 1), round(by, 1))
    return pts


def best_anchor_pair(src_cx, src_cy, src_rx, src_ry,
                     dst_cx, dst_cy, dst_rx, dst_ry, pad=12):
    """Choose the best (src_anchor, dst_anchor) pair for an edge between two nodes.

    Strategy: find the pair of anchor names that minimises the straight-line
    distance between the two anchor points (proxy for the most direct route).
    Returns: (src_name, src_pt, dst_name, dst_pt)
    """
    src_anchors = ellipse_anchors(src_cx, src_cy, src_rx, src_ry, pad=pad)
    dst_anchors = ellipse_anchors(dst_cx, dst_cy, dst_rx, dst_ry, pad=pad)
    best = None
    best_d = float('inf')
    for sn, sp in src_anchors.items():
        for dn, dp in dst_anchors.items():
            d = math.hypot(sp[0] - dp[0], sp[1] - dp[1])
            if d < best_d:
                best_d = d
                best = (sn, sp, dn, dp)
    return best


def ellipse_gap(cx1, cy1, rx1, ry1, cx2, cy2, rx2, ry2):
    """Compute the minimum pixel gap between the surfaces of two ellipses.

    Approximated by sampling 64 boundary points on each ellipse and returning
    the minimum pairwise distance. Returns negative if ellipses overlap.
    """
    def boundary_pts(cx, cy, rx, ry, n=64):
        return [(cx + rx * math.cos(2 * math.pi * i / n),
                 cy + ry * math.sin(2 * math.pi * i / n)) for i in range(n)]
    pts1 = boundary_pts(cx1, cy1, rx1, ry1)
    pts2 = boundary_pts(cx2, cy2, rx2, ry2)
    min_d = float('inf')
    for p1 in pts1:
        for p2 in pts2:
            d = math.hypot(p1[0] - p2[0], p1[1] - p2[1])
            if d < min_d:
                min_d = d
    # If either center is inside the other, gap is negative
    if in_ellipse(cx1, cy1, cx2, cy2, rx2, ry2) or in_ellipse(cx2, cy2, cx1, cy1, rx1, ry1):
        return -min_d
    return round(min_d, 1)


def label_rect_width(text, font_size=12):
    """Auto-compute label rect width from text length."""
    return max(50, int(len(text) * font_size * 0.62 + 16))


# ---------------------------------------------------------------------------
# Bearing-based anchor selection (Option C)
# ---------------------------------------------------------------------------

# Anchor directions as angles in degrees (SVG: y increases downward)
# E=0°, SE=45°, S=90°, SW=135°, W=180°, NW=225°, N=270°, NE=315°
_ANCHOR_ANGLES = {
    'E':  0.0, 'SE': 45.0, 'S':  90.0, 'SW': 135.0,
    'W': 180.0, 'NW': 225.0, 'N': 270.0, 'NE': 315.0,
}
_CARDINAL_ANCHORS = {'N', 'S', 'E', 'W'}
_CARDINAL_BIAS_DEG = 20.0   # snap to cardinal if within this many degrees


def _angle_diff(a, b):
    """Smallest signed angular difference a→b, in [-180, 180]."""
    d = (b - a) % 360.0
    return d - 360.0 if d > 180.0 else d


def bearing_anchor(src_cx, src_cy, src_rx, src_ry,
                   dst_cx, dst_cy, dst_rx, dst_ry,
                   src_pad=12, dst_pad=22):
    """Select anchor pair using bearing angle with cardinal bias.

    Algorithm:
    1. Compute bearing θ from src→dst center (SVG coords, E=0°, CW positive).
    2. For src: pick anchor whose angle is closest to θ. Apply cardinal bias:
       if the best intercardinal is within CARDINAL_BIAS_DEG of a cardinal,
       prefer the cardinal (cleaner visual connection).
    3. For dst: pick anchor closest to θ+180° (facing back toward src), same bias.
    4. Compute curve bend direction: positive = right of chord, negative = left.
       Default: bend away from canvas center, or away from the denser side.

    Returns: (src_name, src_pt, dst_name, dst_pt, bend_sign)
      bend_sign: +1 or -1, to be multiplied by the category's base bend factor.
    """
    # Step 1: bearing from src→dst
    dx, dy = dst_cx - src_cx, dst_cy - src_cy
    bearing = math.degrees(math.atan2(dy, dx)) % 360.0  # E=0, S=90, W=180, N=270

    def _best_anchor_for_bearing(target_angle, biased=True):
        """Return anchor name closest to target_angle, with optional cardinal bias."""
        best_name, best_diff = None, float('inf')
        for name, ang in _ANCHOR_ANGLES.items():
            d = abs(_angle_diff(ang, target_angle))
            if d < best_diff:
                best_diff = d
                best_name = name
        # Cardinal bias: if best is intercardinal and a cardinal is within bias range
        if biased and best_name not in _CARDINAL_ANCHORS:
            for card in _CARDINAL_ANCHORS:
                d = abs(_angle_diff(_ANCHOR_ANGLES[card], target_angle))
                if d <= _CARDINAL_BIAS_DEG:
                    best_name = card
                    break
        return best_name

    src_name = _best_anchor_for_bearing(bearing)
    dst_name = _best_anchor_for_bearing((bearing + 180.0) % 360.0)

    # Step 2: compute anchor points with correct pad
    src_anchors = ellipse_anchors(src_cx, src_cy, src_rx, src_ry, pad=src_pad)
    dst_anchors = ellipse_anchors(dst_cx, dst_cy, dst_rx, dst_ry, pad=dst_pad)
    src_pt = src_anchors[src_name]
    dst_pt = dst_anchors[dst_name]

    # Step 3: bend direction — perpendicular to chord, choose side with more space
    # Cross product of chord with "up" gives left/right. We default to bending
    # upward (negative bend in SVG coords = control point above chord midpoint)
    # unless the chord already runs upward, in which case bend right.
    chord_angle = bearing  # 0=E, 90=S, 180=W, 270=N
    # If chord runs mostly left-right (E or W), bend upward = negative SVG bend
    # If chord runs mostly up-down (N or S), bend rightward = positive SVG bend
    if 45.0 <= chord_angle <= 135.0 or 225.0 <= chord_angle <= 315.0:
        # Chord runs more vertically → bend right (+1)
        bend_sign = 1
    else:
        # Chord runs more horizontally → bend upward (-1 in SVG)
        bend_sign = -1

    return src_name, src_pt, dst_name, dst_pt, bend_sign


def port_assign(edges, nodes):
    """Resolve port conflicts across all edges for a set of nodes.

    Rules:
    1. Spine edges get first pick of anchors (processed before supp/loop/governance).
    2. For each edge, compute the ideal cardinal anchor pair (N/E/S/W) from bearing.
    3. If both ideal anchors are free → assign them.
    4. If an anchor is occupied → try next cardinal first, then diagonals.
       Cardinals are always preferred over diagonals; diagonals are the overflow.
    5. YAML can override anchors explicitly via 'anchor_src' / 'anchor_dst' keys.

    edges: list of dicts with keys: src, dst, category, verb
           optional: anchor_src, anchor_dst (explicit override)
    nodes: dict of node-id → (cx, cy, rx, ry)

    Returns: list of dicts with added keys:
      src_anchor, src_pt, dst_anchor, dst_pt, bend_sign
    """
    # Priority order for processing: spine first, then supp, then governance, then loop
    _PRIORITY = {'spine': 0, 'supp': 1, 'governance': 2, 'loop': 3, 'prevented': 4}

    # Each quadrant has exactly 3 anchors — the two bordering cardinals + the diagonal.
    # We determine which quadrant each node presents toward the other, then find
    # the shortest anchor-to-anchor pair from those 3×3 = 9 combinations.
    _QUADRANT_ANCHORS = {
        'NE': ['N', 'NE', 'E'],
        'SE': ['E', 'SE', 'S'],
        'SW': ['S', 'SW', 'W'],
        'NW': ['W', 'NW', 'N'],
        # Cardinal-only (when bearing is nearly axis-aligned, ±22.5°)
        'E':  ['NE', 'E',  'SE'],
        'S':  ['SE', 'S',  'SW'],
        'W':  ['SW', 'W',  'NW'],
        'N':  ['NW', 'N',  'NE'],
    }

    def _facing_quadrant(bearing_deg):
        """Return the quadrant label a node presents toward a bearing.

        Cardinal zones are widened to ±30° (from ±22.5°) so near-axis bearings
        reliably hit cardinal anchors (N/E/S/W) rather than diagonals.
        """
        b = bearing_deg % 360
        # Wider cardinal zones (±30° from axis)
        if b < 30 or b >= 330:       return 'E'
        if 60  <= b < 120:           return 'S'
        if 150 <= b < 210:           return 'W'
        if 240 <= b < 300:           return 'N'
        # Diagonal zones (remaining 30° wedges)
        if 30  <= b < 60:            return 'SE'
        if 120 <= b < 150:           return 'SW'
        if 210 <= b < 240:           return 'NW'
        return 'NE'  # 300–330

    def _exact_quadrant(bearing_deg):
        """Return the quadrant based on exact bearing with no cardinal zone widening.
        Used for spine edges so the source exits in the actual direction of travel.
        """
        b = bearing_deg % 360
        # Pure 45° octants — no widened cardinal zones
        if b < 22.5 or b >= 337.5:   return 'E'
        if 22.5  <= b < 67.5:        return 'SE'
        if 67.5  <= b < 112.5:       return 'S'
        if 112.5 <= b < 157.5:       return 'SW'
        if 157.5 <= b < 202.5:       return 'W'
        if 202.5 <= b < 247.5:       return 'NW'
        if 247.5 <= b < 292.5:       return 'N'
        return 'NE'  # 292.5–337.5

    # Track used ports per node
    used_ports = {nid: set() for nid in nodes}

    # Penalty added to distance when the DESTINATION uses a diagonal anchor.
    # The source anchor aligns with the travel direction (diagonals OK for source).
    # The destination anchor should be a clean cardinal face where possible.
    _DST_DIAGONAL_PENALTY = 50  # strong preference for cardinal destinations

    def _anchor_bearing_proximity(anchor, bearing_deg):
        """Return angular difference between anchor direction and bearing (0=perfect)."""
        anchor_angle = _ANCHOR_ANGLES.get(anchor, 0)
        diff = abs(((bearing_deg - anchor_angle) + 180) % 360 - 180)
        return diff

    def _best_anchor_pair(src_id, dst_id, src_anchors_map, dst_anchors_map,
                          src_candidates, dst_candidates, src_bearing=None):
        """Pick the free anchor pair that best matches the travel direction.

        Source anchor: chosen by angular proximity to bearing direction (aligns with travel).
        Destination anchor: chosen by shortest distance, with cardinal preference
                            (_DST_DIAGONAL_PENALTY added for diagonal destinations).

        This means:
          - For an SE-traveling edge, the source exits SE (matches direction).
          - The destination receives from its nearest clean cardinal face.
        """
        used_s = used_ports[src_id]
        used_d = used_ports[dst_id]
        best_score = float('inf')
        best_sn = best_dn = None

        def _dst_penalty(anchor):
            return 0 if anchor in _CARDINAL_ANCHORS else _DST_DIAGONAL_PENALTY

        for sn in src_candidates:
            for dn in dst_candidates:
                if sn in used_s or dn in used_d:
                    continue
                sp = src_anchors_map[sn]; dp = dst_anchors_map[dn]
                dist = math.hypot(sp[0] - dp[0], sp[1] - dp[1])
                # Source score: angular proximity to bearing (lower = better match)
                src_score = (_anchor_bearing_proximity(sn, src_bearing)
                             if src_bearing is not None else dist)
                # Combined score: weighted sum of src alignment + dst distance + dst cardinal preference
                score = src_score * 2 + dist + _dst_penalty(dn)
                if score < best_score:
                    best_score = score; best_sn = sn; best_dn = dn

        # Fallback: if all pairs are occupied, allow reuse
        if best_sn is None:
            for sn in src_candidates:
                for dn in dst_candidates:
                    sp = src_anchors_map[sn]; dp = dst_anchors_map[dn]
                    dist = math.hypot(sp[0] - dp[0], sp[1] - dp[1])
                    src_score = (_anchor_bearing_proximity(sn, src_bearing)
                                 if src_bearing is not None else dist)
                    score = src_score * 2 + dist + _dst_penalty(dn)
                    if score < best_score:
                        best_score = score; best_sn = sn; best_dn = dn
        return best_sn, best_dn

    # Sort edges by priority (stable sort preserves declaration order within a tier)
    indexed = list(enumerate(edges))
    indexed.sort(key=lambda ie: _PRIORITY.get(ie[1].get('category', 'supp'), 1))

    result_map = {}

    for orig_idx, edge in indexed:
        src_id, dst_id = edge['src'], edge['dst']
        sc = nodes[src_id]; dc = nodes[dst_id]

        # Bearing from src center → dst center
        dx_c = dc[0] - sc[0]; dy_c = dc[1] - sc[1]
        bearing = math.degrees(math.atan2(dy_c, dx_c)) % 360.0

        # Precompute all anchor points
        sa = ellipse_anchors(sc[0], sc[1], sc[2], sc[3], pad=12)
        da = ellipse_anchors(dc[0], dc[1], dc[2], dc[3], pad=22)

        # Explicit YAML overrides
        if 'anchor_src' in edge and 'anchor_dst' in edge:
            sn = edge['anchor_src'].upper()
            dn = edge['anchor_dst'].upper()
        else:
            # For spine edges flowing right+down: force SE source quadrant so the
            # source exits from the SE corner, emphasising the diagonal spine direction.
            # For spine flowing other directions, use exact quadrant.
            # For non-spine edges: use wider cardinal zones for cleaner arrival faces.
            _forced_src_anchor = None
            if edge.get('category') == 'spine':
                # Force the source to exit from the diagonal corner that matches
                # the spine's flow direction. This gives SE→W for a right+down spine,
                # making the connection visually emphasise the diagonal direction.
                dx_c2 = nodes[dst_id][0] - nodes[src_id][0]
                dy_c2 = nodes[dst_id][1] - nodes[src_id][1]
                if dx_c2 > 0 and dy_c2 >= 0:
                    _forced_src_anchor = 'SE'
                elif dx_c2 > 0 and dy_c2 < 0:
                    _forced_src_anchor = 'NE'
                elif dx_c2 < 0 and dy_c2 >= 0:
                    _forced_src_anchor = 'SW'
                else:
                    _forced_src_anchor = 'NW'
                src_quad = _forced_src_anchor  # quadrant = the forced anchor
            else:
                src_quad = _facing_quadrant(bearing)
            dst_quad = _facing_quadrant((bearing + 180.0) % 360.0)
            src_candidates = _QUADRANT_ANCHORS[src_quad]
            dst_candidates = _QUADRANT_ANCHORS[dst_quad]

            if 'anchor_src' in edge:
                sn = edge['anchor_src'].upper()
                # Fix src, find best free dst from its candidates
                sp_fixed = sa[sn]
                best_dist = float('inf'); dn = dst_candidates[0]
                used_d = used_ports[dst_id]
                for cdn in dst_candidates:
                    if cdn in used_d: continue
                    d = math.hypot(sp_fixed[0]-da[cdn][0], sp_fixed[1]-da[cdn][1])
                    if d < best_dist: best_dist = d; dn = cdn
            elif 'anchor_dst' in edge:
                dn = edge['anchor_dst'].upper()
                dp_fixed = da[dn]
                best_dist = float('inf'); sn = src_candidates[0]
                used_s = used_ports[src_id]
                for csn in src_candidates:
                    if csn in used_s: continue
                    d = math.hypot(da[dn][0]-sa[csn][0], da[dn][1]-sa[csn][1])
                    if d < best_dist: best_dist = d; sn = csn
            elif edge.get('category') == 'loop':
                # Loop edges: source exits from the "back corner" facing away from
                # the diagram center. Destination prefers N if source is above, S if below,
                # W if to the right, E if to the left — the side the loop "arrives from".
                # This gives NW→N for a loop from above-right back to a left node.
                dst_quad = _facing_quadrant((bearing + 180.0) % 360.0)
                # Override destination: prefer the cardinal that the loop arrives "from above"
                # i.e. if the source has a higher y than destination (source is below in SVG),
                # arrive at S; if source has lower y (source is above), arrive at N.
                sc2 = nodes[src_id]; dc2 = nodes[dst_id]
                if sc2[1] < dc2[1]:  # source is above destination in SVG → arrive at top (N)
                    preferred_dst = 'N'
                elif sc2[1] > dc2[1]:  # source is below → arrive at bottom (S)
                    preferred_dst = 'S'
                elif sc2[0] < dc2[0]:  # source is left → arrive at left (W)
                    preferred_dst = 'W'
                else:
                    preferred_dst = 'E'
                dn = preferred_dst if preferred_dst not in used_ports[dst_id] else dst_candidates[0]
                # Source: pick the anchor that points away from centroid (outward)
                sn, _ = _best_anchor_pair(src_id, dst_id, sa, da,
                                          src_candidates, dst_candidates,
                                          src_bearing=bearing)
            elif _forced_src_anchor is not None:
                # Spine edge: use forced diagonal source anchor directly.
                # If occupied, fall back to best from candidates.
                if _forced_src_anchor not in used_ports[src_id]:
                    sn = _forced_src_anchor
                else:
                    sn = next((a for a in src_candidates if a not in used_ports[src_id]),
                               _forced_src_anchor)
                # Find best free dst anchor
                sp_fixed = sa[sn]
                best_dist = float('inf'); dn = dst_candidates[0]
                for cdn in dst_candidates:
                    if cdn in used_ports[dst_id]: continue
                    d = math.hypot(sp_fixed[0]-da[cdn][0], sp_fixed[1]-da[cdn][1])
                    if d < best_dist: best_dist = d; dn = cdn
            else:
                sn, dn = _best_anchor_pair(src_id, dst_id, sa, da,
                                           src_candidates, dst_candidates,
                                           src_bearing=bearing)

        sp = sa[sn]; dp = da[dn]

        # Mark ports used
        if 'anchor_src' not in edge: used_ports[src_id].add(sn)
        if 'anchor_dst' not in edge: used_ports[dst_id].add(dn)

        # Bend sign from bearing_anchor
        _, _, _, _, bs = bearing_anchor(sc[0], sc[1], sc[2], sc[3],
                                        dc[0], dc[1], dc[2], dc[3])

        result_map[orig_idx] = {**edge, 'src_anchor': sn, 'src_pt': sp,
                                 'dst_anchor': dn, 'dst_pt': dp, 'bend_sign': bs}

    return [result_map[i] for i in range(len(edges))]


# ---------------------------------------------------------------------------
# SVG boilerplate helpers
# ---------------------------------------------------------------------------

SVG_DEFS = """\
  <defs>
    <style>text { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }</style>
    <filter id="sh" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="2" dy="3" stdDeviation="4" flood-color="#00000022"/>
    </filter>
    <radialGradient id="gGreen" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#E3FCEF"/>
      <stop offset="100%" stop-color="#ABF5D1"/>
    </radialGradient>
    <radialGradient id="gBlue" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#DEEBFF"/>
      <stop offset="100%" stop-color="#B3D4FF"/>
    </radialGradient>
    <radialGradient id="gPurple" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#EAE6FF"/>
      <stop offset="100%" stop-color="#C0B6F2"/>
    </radialGradient>
    <radialGradient id="gRed" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#FFEBE6"/>
      <stop offset="100%" stop-color="#FFBDAD"/>
    </radialGradient>
    <radialGradient id="gGray" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#F4F5F7"/>
      <stop offset="100%" stop-color="#DFE1E6"/>
    </radialGradient>
    <radialGradient id="gAmber" cx="35%" cy="35%" r="75%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#FFFAE6"/>
      <stop offset="100%" stop-color="#FFE380"/>
    </radialGradient>
    <marker id="arrGreen" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
      <path d="M0,0 L9,3.5 L0,7 z" fill="#00875A"/></marker>
    <marker id="arrBlue" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
      <path d="M0,0 L9,3.5 L0,7 z" fill="#0747A6"/></marker>
    <marker id="arrPurple" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
      <path d="M0,0 L9,3.5 L0,7 z" fill="#5243AA"/></marker>
    <marker id="arrRed" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
      <path d="M0,0 L9,3.5 L0,7 z" fill="#BF2600"/></marker>
    <marker id="arrGray" markerWidth="9" markerHeight="7" refX="8" refY="3.5" orient="auto">
      <path d="M0,0 L9,3.5 L0,7 z" fill="#42526E"/></marker>
    <marker id="arrAmber" markerWidth="11" markerHeight="9" refX="9" refY="4.5" orient="auto">
      <path d="M0,0 L11,4.5 L0,9 z" fill="#974F00"/></marker>
  </defs>"""


# ---------------------------------------------------------------------------
# Subcommand: init
# ---------------------------------------------------------------------------

def cmd_init(args):
    """Write empty SVG boilerplate with all defs."""
    w, h = args.width, args.height
    svg = (
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="0 0 {w} {h}" width="{w}" height="{h}">\n'
        f'  <rect width="{w}" height="{h}" fill="white"/>\n'
        f'{SVG_DEFS}\n'
        f'  <!-- nodes -->\n\n'
        f'  <!-- edges -->\n'
        f'</svg>\n'
    )
    if args.output == '-':
        print(svg, end='')
    else:
        with open(args.output, 'w') as f:
            f.write(svg)
        print(f'Wrote {args.output} ({w}x{h})')


# ---------------------------------------------------------------------------
# Subcommand: node
# ---------------------------------------------------------------------------

def cmd_node(args):
    """Emit <g> snippet for a node ellipse with text lines."""
    d, t = DOMAIN[args.domain], TIER[args.tier]
    cx, cy, rx, ry = args.cx, args.cy, args.rx, args.ry
    has_sub, has_ch = args.sub_mission is not None, args.children is not None
    n = 1 + has_sub + has_ch
    y0 = cy + 5 if n == 1 else cy - 8 if n == 2 else cy - 18
    out = [
        f'<g id="{args.id}">',
        f'  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="url(#{d["grad"]})"'
        f' stroke="{d["stroke"]}" stroke-width="{t["stroke_width"]}" filter="url(#sh)"/>',
        f'  <text x="{cx}" y="{y0}" text-anchor="middle" font-size="{t["title_size"]}"'
        f' font-weight="{t["title_weight"]}" fill="{d["text"]}">{args.title}</text>',
    ]
    if has_sub:
        out.append(f'  <text x="{cx}" y="{y0+20}" text-anchor="middle" font-size="12"'
                   f' font-style="italic" fill="{d["text"]}">{args.sub_mission}</text>')
        if has_ch:
            out.append(f'  <text x="{cx}" y="{y0+40}" text-anchor="middle" font-size="12"'
                       f' fill="{d["text"]}">{args.children}</text>')
    elif has_ch:
        out.append(f'  <text x="{cx}" y="{y0+20}" text-anchor="middle" font-size="12"'
                   f' fill="{d["text"]}">{args.children}</text>')
    out.append('</g>')
    print('\n'.join(out))


def cmd_edge(args):
    """Compute and emit a quadratic Bezier edge with verb label."""
    sx, sy, srx, sry = args.src_x, args.src_y, args.src_rx, args.src_ry
    dx, dy, drx, dry = args.dst_x, args.dst_y, args.dst_rx, args.dst_ry
    cat = CATEGORY[args.category]
    bend = args.bend if args.bend is not None else cat['bend']
    if args.hint == 'left': bend = -bend
    force = cat['force_color']
    ci = DOMAIN[force] if force else DOMAIN.get(getattr(args, 'domain', 'gray'), DOMAIN['gray'])
    sw, dash = cat['width'], f' stroke-dasharray="{cat["dash"]}"' if cat['dash'] else ''
    p1x, p1y = edge_pt(sx, sy, srx, sry, dx, dy, pad=0)
    p2x, p2y = edge_pt(dx, dy, drx, dry, sx, sy, pad=args.pad)
    cx, cy = quad_ctrl(p1x, p1y, p2x, p2y, bend)
    lx, ly = quad_mid(p1x, p1y, cx, cy, p2x, p2y)
    lx, ly, w = round(lx, 1), round(ly, 1), label_rect_width(args.verb)
    lines = [
        f'<path d="M {p1x},{p1y} Q {cx},{cy} {p2x},{p2y}"',
        f'      stroke="{ci["stroke"]}" stroke-width="{sw}" fill="none"{dash} marker-end="url(#{ci["arrow"]})"/>',
        f'<rect x="{round(lx-w/2,1)}" y="{round(ly-11,1)}" width="{w}" height="22" rx="3"',
        f'      fill="white" stroke="{ci["stroke"]}" stroke-width="1"/>',
        f'<text x="{lx}" y="{round(ly+4,1)}" text-anchor="middle"',
        f'      font-size="12" font-weight="600" fill="{ci["text"]}">{args.verb}</text>',
    ]
    print('\n'.join(lines))


def cmd_geom(args):
    """Pure geometry helpers — print numeric results."""
    sub = args.geom_sub

    if sub == 'boundary':
        result = edge_pt(args.cx, args.cy, args.rx, args.ry, args.px, args.py, pad=args.pad)
        print(f'({result[0]}, {result[1]})')

    elif sub == 'ctrl':
        result = quad_ctrl(args.x1, args.y1, args.x2, args.y2, args.bend)
        print(f'({result[0]}, {result[1]})')

    elif sub == 'midpoint':
        mode = args.curve_type
        if mode == 'quad':
            mx, my = quad_mid(args.x1, args.y1, args.cx, args.cy, args.x2, args.y2)
            print(f'({round(mx, 1)}, {round(my, 1)})')
        elif mode == 'cubic':
            mx, my = cubic_mid(args.x1, args.y1, args.c1x, args.c1y,
                                args.c2x, args.c2y, args.x2, args.y2)
            print(f'({round(mx, 1)}, {round(my, 1)})')

    elif sub == 'in_ellipse':
        result = in_ellipse(args.px, args.py, args.cx, args.cy, args.rx, args.ry)
        print('true' if result else 'false')

    elif sub == 'anchors':
        pad = getattr(args, 'pad', 0)
        pts = ellipse_anchors(args.cx, args.cy, args.rx, args.ry, pad=pad)
        for name in _ANCHOR_ORDER:
            x, y = pts[name]
            print(f'{name:2s}  ({x}, {y})')

    elif sub == 'best_anchor':
        pad = getattr(args, 'pad', 12)
        sn, sp, dn, dp = best_anchor_pair(
            args.src_cx, args.src_cy, args.src_rx, args.src_ry,
            args.dst_cx, args.dst_cy, args.dst_rx, args.dst_ry, pad=pad)
        print(f'src  {sn:2s}  ({sp[0]}, {sp[1]})')
        print(f'dst  {dn:2s}  ({dp[0]}, {dp[1]})')

    elif sub == 'gap':
        g = ellipse_gap(args.cx1, args.cy1, args.rx1, args.ry1,
                        args.cx2, args.cy2, args.rx2, args.ry2)
        status = 'OK' if g >= 120 else ('WARNING: gap < 120px' if g >= 0 else 'ERROR: ellipses overlap')
        print(f'gap  {g}px  [{status}]')

    elif sub == 'bearing':
        sn, sp, dn, dp, bs = bearing_anchor(
            args.src_cx, args.src_cy, args.src_rx, args.src_ry,
            args.dst_cx, args.dst_cy, args.dst_rx, args.dst_ry)
        dx = args.dst_cx - args.src_cx; dy = args.dst_cy - args.src_cy
        bearing_deg = math.degrees(math.atan2(dy, dx)) % 360.0
        bend_dir = 'right-of-chord (+)' if bs > 0 else 'left-of-chord (-)'
        print(f'bearing     {bearing_deg:.1f}°')
        print(f'src anchor  {sn:2s}  ({sp[0]}, {sp[1]})')
        print(f'dst anchor  {dn:2s}  ({dp[0]}, {dp[1]})')
        print(f'bend dir    {bend_dir}')


# ---------------------------------------------------------------------------
# Subcommand: arrow
# ---------------------------------------------------------------------------

def cmd_arrow(args):
    """Emit styled path for an arrow given start, end, and desired apex."""
    x1, y1, x2, y2 = args.x1, args.y1, args.x2, args.y2
    ax, ay = args.apex[0], args.apex[1]

    # Solve for control point: M = 0.25*(P0+P2) + 0.5*P1  =>  P1 = 2*M - 0.5*(P0+P2)
    cx = 2 * ax - 0.5 * (x1 + x2)
    cy = 2 * ay - 0.5 * (y1 + y2)
    cx, cy = round(cx, 1), round(cy, 1)

    style = args.style
    if style in CATEGORY:
        cat = CATEGORY[style]
        force = cat['force_color']
        color_info = DOMAIN[force] if force else DOMAIN['gray']
        sw = cat['width']
        dash_attr = f' stroke-dasharray="{cat["dash"]}"' if cat['dash'] else ''
    elif style in DOMAIN:
        # allow domain names as shorthand
        color_info = DOMAIN[style]
        sw = CATEGORY['spine']['width']
        dash_attr = ''
    else:
        color_info = DOMAIN['gray']
        sw = CATEGORY['spine']['width']
        dash_attr = ''

    stroke = color_info['stroke']
    arrow_id = color_info['arrow']

    print(
        f'<path d="M {x1},{y1} Q {cx},{cy} {x2},{y2}"\n'
        f'      stroke="{stroke}" stroke-width="{sw}" fill="none"'
        f'{dash_attr} marker-end="url(#{arrow_id})"/>'
    )


# ---------------------------------------------------------------------------
# Subcommand: loop
# ---------------------------------------------------------------------------

def cmd_loop(args):
    """Emit multi-segment cubic Bezier loop edge with verb label."""
    sx, sy, srx, sry = args.src_x, args.src_y, args.src_rx, args.src_ry
    dx, dy, drx, dry = args.dst_x, args.dst_y, args.dst_rx, args.dst_ry
    vx, vy = args.via[0], args.via[1]
    has2 = args.via2 is not None
    if has2: v2x, v2y = args.via2[0], args.via2[1]
    p1x, p1y = edge_pt(sx, sy, srx, sry, vx, vy, pad=10)
    lv, lvv = (v2x, v2y) if has2 else (vx, vy)
    p2x, p2y = edge_pt(dx, dy, drx, dry, lv, lvv, pad=10)
    ci = DOMAIN['amber']; sw = CATEGORY['loop']['width']
    if not has2:
        c1x, c1y = round(vx+(p1x-vx)*0.4,1), round(vy+(p1y-vy)*0.4,1)
        c2x, c2y = round(vx+(p2x-vx)*0.4,1), round(vy+(p2y-vy)*0.4,1)
        pd = f'M {p1x},{p1y} C {c1x},{c1y} {c2x},{c2y} {p2x},{p2y}'
        lx, ly = cubic_mid(p1x, p1y, c1x, c1y, c2x, c2y, p2x, p2y)
    else:
        c1x,c1y = round(p1x+(vx-p1x)*0.6,1), round(p1y+(vy-p1y)*0.6,1)
        c2x,c2y = round(vx+(v2x-vx)*0.2,1),  round(vy+(v2y-vy)*0.2,1)
        c3x,c3y = round(vx+(v2x-vx)*0.8,1),  round(vy+(v2y-vy)*0.8,1)
        c4x,c4y = round(p2x+(v2x-p2x)*0.4,1),round(p2y+(v2y-p2y)*0.4,1)
        pd = (f'M {p1x},{p1y} C {c1x},{c1y} {c2x},{c2y} {vx},{vy}'
              f' C {c3x},{c3y} {c4x},{c4y} {p2x},{p2y}')
        lx, ly = (vx+v2x)/2, (vy+v2y)/2
    lx, ly, w = round(lx,1), round(ly,1), label_rect_width(args.verb)
    print('\n'.join([
        f'<path d="{pd}"',
        f'      stroke="{ci["stroke"]}" stroke-width="{sw}" fill="none" marker-end="url(#{ci["arrow"]})"/>',
        f'<rect x="{round(lx-w/2,1)}" y="{round(ly-11,1)}" width="{w}" height="22" rx="3"',
        f'      fill="white" stroke="{ci["stroke"]}" stroke-width="1"/>',
        f'<text x="{lx}" y="{round(ly+4,1)}" text-anchor="middle"',
        f'      font-size="12" font-weight="600" fill="{ci["text"]}">{args.verb}</text>',
    ]))


_PLURAL_VERBS = re.compile(
    r'^(are|have|do|make|build|create|provide|define|enable|support|constrain|contain|'
    r'produce|manage|own|run|generate|use|send|receive|allow|prevent|block|drive|lead|'
    r'control|deliver|serve|require|include|deploy|configure|monitor|connect|integrate|'
    r'feed|publish|update|trigger|enforce|validate|process)$', re.IGNORECASE)


def cmd_spine(args):
    """Parse a noun→verb→noun chain and print triples with tense warnings."""
    tokens = args.chain
    if len(tokens) < 3:
        print('ERROR: spine requires at least: noun verb noun', file=sys.stderr)
        sys.exit(1)

    # Alternate: noun verb noun verb noun ...
    # tokens[0] = noun, tokens[1] = verb, tokens[2] = noun, etc.
    nodes = []
    verbs = []
    for i, tok in enumerate(tokens):
        if i % 2 == 0:
            nodes.append(tok)
        else:
            verbs.append(tok)

    if len(nodes) < 2:
        print('ERROR: chain must have at least 2 nouns and 1 verb.', file=sys.stderr)
        sys.exit(1)

    edge_count = min(len(nodes) - 1, len(verbs))
    warnings = []

    for i in range(edge_count):
        src = nodes[i]
        verb = verbs[i]
        dst = nodes[i + 1]
        print(f'  {src} → {verb} → {dst}')
        if _PLURAL_VERBS.match(verb):
            warnings.append(f"WARNING: '{verb}' is plural form — use '{verb}s' for present-tense singular consistency")

    print(f'\n{edge_count} edge{"s" if edge_count != 1 else ""}, {len(nodes)} nodes')
    for w in warnings:
        print(w)


# ---------------------------------------------------------------------------
# Subcommand: validate
# ---------------------------------------------------------------------------

def _fa(val, default=0.0):
    """Parse float from SVG attribute string."""
    if val is None: return default
    try: return float(re.sub(r'[^0-9.\-]', '', val))
    except ValueError: return default

# Keep old name as alias for readability in cmd_validate
_parse_float_attr = _fa


def _sample_path_points(d, n=21):
    """Sample n points along M...Q.../M...C... SVG path. Returns [(x,y)]."""
    try:
        m = re.match(r'M\s*([-\d.]+)[,\s]+([-\d.]+)', d.strip())
        if not m: return []
        cx, cy = float(m.group(1)), float(m.group(2))
        pts = []
        for cmd, cstr in re.findall(r'([MCQmcq])\s*((?:[-+]?\d*\.?\d+[,\s]+)*[-+]?\d*\.?\d+)', d):
            ns = [float(v) for v in re.findall(r'[-+]?\d*\.?\d+', cstr)]
            if cmd == 'M':
                cx, cy = ns[0], ns[1]
            elif cmd == 'C':
                i = 0
                while i + 5 < len(ns):
                    c1x,c1y,c2x,c2y,ex,ey = ns[i:i+6]
                    for j in range(n+1):
                        t=j/n; u=1-t
                        pts.append((u**3*cx+3*u**2*t*c1x+3*u*t**2*c2x+t**3*ex,
                                    u**3*cy+3*u**2*t*c1y+3*u*t**2*c2y+t**3*ey))
                    cx,cy=ex,ey; i+=6
            elif cmd == 'Q':
                i = 0
                while i + 3 < len(ns):
                    qcx,qcy,ex,ey = ns[i:i+4]
                    for j in range(n+1):
                        t=j/n; u=1-t
                        pts.append((u**2*cx+2*u*t*qcx+t**2*ex,
                                    u**2*cy+2*u*t*qcy+t**2*ey))
                    cx,cy=ex,ey; i+=4
        return pts or [(float(m.group(1)), float(m.group(2)))]
    except Exception:
        return []


def _ellipse_from_elem(elem):
    """Extract (cx, cy, rx, ry) from an <ellipse> element."""
    return (_fa(elem.get('cx'), 0.0), _fa(elem.get('cy'), 0.0),
            _fa(elem.get('rx'), 0.0), _fa(elem.get('ry'), 0.0))


def cmd_validate(args):
    """Parse SVG and run 9 cardinal-rule checks."""
    path_in, use_json = args.input, getattr(args, 'json', False)
    checks, issues = [], []

    # Rule 1: XML parses cleanly
    try:
        root = ET.parse(path_in).getroot()
        checks.append(('XML valid', True, ''))
    except ET.ParseError as e:
        checks.append(('XML valid', False, str(e)))
        _vreport(path_in, checks, issues, use_json); return

    for elem in root.iter():  # strip namespaces
        if '}' in elem.tag: elem.tag = elem.tag.split('}', 1)[1]

    vb = re.findall(r'[-\d.]+', root.get('viewBox', ''))
    canvas_w = float(vb[2]) if len(vb) == 4 else _fa(root.get('width'), 1280)
    canvas_h = float(vb[3]) if len(vb) == 4 else _fa(root.get('height'), 960)

    ellipses = [_ellipse_from_elem(e) for e in root.iter('ellipse')]
    mk_ids = {id(p) for mk in root.iter('marker') for p in mk.iter('path')}
    paths = [p for p in root.iter('path') if id(p) not in mk_ids]
    def_ids = {id(e) for d in root.iter('defs') for e in d.iter()}
    texts = [t for t in root.iter('text') if id(t) not in def_ids]
    rects = [r for r in root.iter('rect') if id(r) not in def_ids]

    def ck(name, ok, detail=''):
        checks.append((name, ok, detail))
        if not ok: issues.append(f'{"⚠" if "node" in name or "clearance" in name else "✗"} {detail or name}')

    # Rule 2: font-sizes >= 12
    bad_fs = [f'fs={_fa(t.get("font-size"), 12):.0f} "{(t.text or "")[:20]}"'
              for t in texts if _fa(t.get('font-size'), 12.0) < 12.0]
    ck('Font sizes ≥ 12px', not bad_fs,
       f'{len(texts)}/{len(texts)} ≥ 12px' if not bad_fs else '; '.join(bad_fs[:3]))

    # Rule 3: gradient count <= 6
    gc = sum(1 for e in root.iter() if e.tag in ('radialGradient', 'linearGradient'))
    ck('Gradient count ≤ 6', gc <= 6, f'{gc} ≤ 6' if gc <= 6 else f'{gc} gradients > 6')

    # Rule 4: all paths have marker-end
    nm = [p for p in paths if not p.get('marker-end')]
    ck('All paths are arrows', not nm,
       f'All {len(paths)} paths are arrows' if not nm else f'{len(nm)}/{len(paths)} missing marker-end')

    # Rule 5: every arrow has a nearby label rect
    def _has_label(p):
        d = p.get('d', ''); pts = _sample_path_points(d)
        if not pts: return True
        mx, my = pts[len(pts)//2]
        return any(math.hypot(_fa(r.get('x'),0)+_fa(r.get('width'),0)/2 - mx,
                               _fa(r.get('y'),0)+_fa(r.get('height'),0)/2 - my) < 60
                   for r in rects)
    unlabelled = [p for p in paths if not _has_label(p)]
    ck('All arrows have labels', not unlabelled,
       f'All {len(paths)} arrows have labels' if not unlabelled else f'{len(unlabelled)} arrow(s) missing labels')

    # Rule 6: all labels horizontal
    rot = [(t.text or '').strip()[:20] for t in texts if 'rotate' in (t.get('transform') or '').lower()]
    ck('All labels horizontal', not rot, '' if not rot else f'Rotated: {", ".join(rot[:3])}')

    # Rule 7: no path-through-node
    ptn = []
    for p in paths:
        pts = _sample_path_points(p.get('d', ''))
        if len(pts) < 3: continue
        # Identify terminal ellipses (source and destination nodes).
        # Use pad=40 to robustly catch endpoints that land slightly outside due to
        # port geometry — the curve is allowed to pass through terminal nodes near endpoints.
        term = {ei for ei, e in enumerate(ellipses)
                if in_ellipse(pts[0][0], pts[0][1], *e, pad=40) or in_ellipse(pts[-1][0], pts[-1][1], *e, pad=40)}
        for sp in pts[1:-1]:
            for ei, e in enumerate(ellipses):
                if ei not in term and in_ellipse(sp[0], sp[1], *e):
                    ptn.append(f'Sample ({sp[0]:.0f},{sp[1]:.0f}) inside ellipse ({e[0]},{e[1]})'); break
    ck('No path-through-node', not ptn, '' if not ptn else f'{len(ptn)} violation(s): {ptn[0]}')

    # Rule 8: arrowhead clearance >= 10px
    ci = []
    for p in paths:
        pts = _sample_path_points(p.get('d', ''))
        if not pts: continue
        ep = pts[-1]
        close = [(math.hypot(ep[0]-edge_pt(*e, ep[0], ep[1])[0], ep[1]-edge_pt(*e, ep[0], ep[1])[1]), e)
                 for e in ellipses if e[2] > 0 and e[3] > 0 and not in_ellipse(ep[0], ep[1], *e)]
        if close:
            d_min, e_min = min(close, key=lambda x: x[0])
            if d_min < 10: ci.append(f'Arrowhead ({ep[0]:.0f},{ep[1]:.0f}) {d_min:.1f}px from ({e_min[0]},{e_min[1]})')
    ck('Arrowhead clearance ≥ 10px', not ci, '' if not ci else ci[0])

    # Rule 9: no label rect overlaps ellipse
    lo = []
    for r in rects:
        rx, ry2, rw, rh = _fa(r.get('x')), _fa(r.get('y')), _fa(r.get('width')), _fa(r.get('height'))
        corners = [(rx,ry2),(rx+rw,ry2),(rx,ry2+rh),(rx+rw,ry2+rh),(rx+rw/2,ry2+rh/2)]
        for e in ellipses:
            if any(in_ellipse(cx, cy, *e) for cx, cy in corners):
                lo.append(f'Rect [{rx:.0f},{ry2:.0f}]-[{rx+rw:.0f},{ry2+rh:.0f}] overlaps ({e[0]},{e[1]})')
                break
    ck('No label-ellipse overlap', not lo, '' if not lo else lo[0])

    # Rule 10: no label rect overlaps its arrow's arrowhead zone
    # For each path, find the nearest label rect and check it doesn't contain the endpoint.
    ah_issues = []
    for p in paths:
        pts = _sample_path_points(p.get('d', ''))
        if not pts: continue
        ep = pts[-1]  # arrowhead endpoint
        # Find the label rect closest to the path midpoint
        mid = pts[len(pts)//2]
        nearest_r = None
        nearest_d = float('inf')
        for r in rects:
            rxx = _fa(r.get('x')); ryy = _fa(r.get('y'))
            rw = _fa(r.get('width')); rh = _fa(r.get('height'))
            rc_x = rxx + rw/2; rc_y = ryy + rh/2
            d = math.hypot(rc_x - mid[0], rc_y - mid[1])
            if d < nearest_d:
                nearest_d = d; nearest_r = (rxx, ryy, rw, rh)
        if nearest_r and nearest_d < 80:  # only check if reasonably close
            rxx, ryy, rw, rh = nearest_r
            buf = 15
            if (rxx - buf) < ep[0] < (rxx + rw + buf) and (ryy - buf) < ep[1] < (ryy + rh + buf):
                ah_issues.append(f'Label rect [{rxx:.0f},{ryy:.0f}] overlaps arrowhead at ({ep[0]:.0f},{ep[1]:.0f})')
    ck('No label-arrowhead overlap', not ah_issues, '' if not ah_issues else ah_issues[0])

    _vreport(path_in, checks, issues, use_json, canvas_w, canvas_h)


def _vreport(path_in, checks, issues, use_json, canvas_w=1280, canvas_h=960):
    """Print the structured validation report."""
    if use_json:
        import json
        print(json.dumps({'file': path_in, 'canvas': {'width': canvas_w, 'height': canvas_h},
                          'checks': [{'rule': c[0], 'passed': c[1], 'detail': c[2]} for c in checks],
                          'issues': issues, 'passed': sum(c[1] for c in checks), 'total': len(checks)}, indent=2))
        return
    n_pass, n_total = sum(c[1] for c in checks), len(checks)
    print(f'SYSTEMIGRAM VALIDATION REPORT\nFile: {path_in}\nCanvas: {canvas_w:.0f} × {canvas_h:.0f}\n')
    for rule, ok, detail in checks:
        print(f'{"✓" if ok else "✗"} {rule}' + (f': {detail}' if detail else ''))
    if issues:
        print()
        for iss in issues: print(iss)
    print()
    if n_pass == n_total:
        print(f'PASSED: {n_pass}/{n_total} checks — all clear ✓')
    else:
        print(f'PASSED: {n_pass}/{n_total} checks\nFAILED: {n_total-n_pass} issue{"s" if n_total-n_pass!=1 else ""} — see above')


AGENT_HELP_TIER2 = {
    'init':     "init <out.svg> [--width W] [--height H]\n  Write SVG boilerplate (6 gradients, 6 markers, shadow). Default 1280x960.\n  Ex: python systemigram.py init diagram.svg\n",
    'node':     "node <id> <cx> <cy> <rx> <ry> <domain> <title> [--sub-mission T] [--children T] [--tier hero|primary|secondary]\n  Emit <g> ellipse+1-3 text lines. domain: green|blue|purple|red|gray|amber. tier default: primary.\n  Ex: python systemigram.py node IP 200 150 140 78 green \"Identity Platform\"\n",
    'edge':     "edge <sx> <sy> <srx> <sry> <dx> <dy> <drx> <dry> <verb> <cat> [--bend F] [--hint left|right] [--pad N]\n  Boundary pts (pad>=10), quad Bezier ctrl, t=0.5 label. cat: spine|gov|supp|loop|prevent|anchors.\n  Ex: python systemigram.py edge 200 150 140 78 640 150 140 68 publishes spine\n",
    'arrow':    "arrow <x1> <y1> <x2> <y2> --apex <ax> <ay> [--style CAT|DOMAIN]\n  Ctrl pt from apex: P1=2*M-0.5*(P0+P2). Emits path only (no label). Default style: spine.\n  Ex: python systemigram.py arrow 200 500 1080 500 --apex 640 440\n",
    'loop':     "loop <sx> <sy> <srx> <sry> <dx> <dy> <drx> <dry> <verb> --via <vx> <vy> [--via2 <v2x> <v2y>]\n  Cubic Bezier through 1-2 via points. Label at via midpoint. Boundary pad=10.\n  Ex: python systemigram.py loop 820 730 150 78 640 150 140 68 feeds-new --via 900 400\n",
    'spine':    "spine <noun> <verb> <noun> <verb> ... (alternating)\n  Print node->verb->node triples. Warns on plural verb forms.\n  Ex: python systemigram.py spine \"Identity Platform\" publishes Specs constrains Teams\n",
    'validate': "validate <input.svg> [--json]\n  9 checks: XML valid, font>=12, gradients<=6, all paths arrow, labels present+horizontal,\n  no path-through-node, arrowhead clearance>=10, no label-ellipse overlap.\n  Ex: python systemigram.py validate diagram.svg\n",
    'geom':     ("geom anchors <cx> <cy> <rx> <ry> [--pad 12]\n"
                 "  8 named anchor pts (N/NE/E/SE/S/SW/W/NW) on ellipse boundary. Use --pad 12 for connectors.\n"
                 "  Ex: python systemigram.py geom anchors 400 300 120 60 --pad 12\n\n"
                 "geom best_anchor <src_cx> <src_cy> <src_rx> <src_ry> <dst_cx> <dst_cy> <dst_rx> <dst_ry> [--pad 12]\n"
                 "  Auto-select closest src+dst anchor pair for an edge. Always run before computing ctrl pts.\n"
                 "  Ex: python systemigram.py geom best_anchor 200 400 100 55 600 300 110 60\n\n"
                 "geom gap <cx1> <cy1> <rx1> <ry1> <cx2> <cy2> <rx2> <ry2>\n"
                 "  Min surface-to-surface gap between two ellipses. Must be ≥120px. Run before any edge geometry.\n"
                 "  Ex: python systemigram.py geom gap 200 450 100 55 500 450 100 55\n\n"
                 "geom boundary <cx> <cy> <rx> <ry> <px> <py> [--pad N]\n"
                 "geom ctrl <x1> <y1> <x2> <y2> --bend <b>\n"
                 "geom midpoint quad <x1> <y1> <cx> <cy> <x2> <y2>\n"
                 "geom midpoint cubic <x1> <y1> <c1x> <c1y> <c2x> <c2y> <x2> <y2>\n"
                 "geom in_ellipse <px> <py> <cx> <cy> <rx> <ry>\n"
                 "  Lower-level math helpers. Prefer anchors/best_anchor/gap for layout work.\n"),
}


# ---------------------------------------------------------------------------
# Argument parser
# ---------------------------------------------------------------------------

def build_parser():
    A = argparse.ArgumentParser
    p = A(prog='systemigram.py', description='SVG geometry + snippet CLI for systemigrams.')
    p.add_argument('--agent-help', nargs='?', const='__tier1__', metavar='CMD', dest='agent_help')
    sub = p.add_subparsers(dest='command')

    # init
    pi = sub.add_parser('init'); pi.add_argument('output'); pi.add_argument('--width', type=int, default=1280); pi.add_argument('--height', type=int, default=960)

    # node  (positional order: id cx cy rx ry domain title)
    pn = sub.add_parser('node')
    for a in ('id', 'cx:f', 'cy:f', 'rx:f', 'ry:f'):
        if ':f' in a: pn.add_argument(a.split(':')[0], type=float)
        else: pn.add_argument(a)
    pn.add_argument('domain', choices=list(DOMAIN))
    pn.add_argument('title')
    pn.add_argument('--sub-mission', dest='sub_mission', default=None)
    pn.add_argument('--children', default=None)
    pn.add_argument('--tier', choices=list(TIER), default='primary')

    # edge
    pe = sub.add_parser('edge')
    for a in ('src_x', 'src_y', 'src_rx', 'src_ry', 'dst_x', 'dst_y', 'dst_rx', 'dst_ry'):
        pe.add_argument(a, type=float)
    pe.add_argument('verb'); pe.add_argument('category', choices=list(CATEGORY))
    pe.add_argument('--bend', type=float, default=None); pe.add_argument('--hint', choices=['left','right'], default='right')
    pe.add_argument('--pad', type=float, default=10); pe.add_argument('--domain', choices=list(DOMAIN), default='gray')

    # arrow
    pa = sub.add_parser('arrow')
    pa.add_argument('x1', type=float); pa.add_argument('y1', type=float)
    pa.add_argument('x2', type=float); pa.add_argument('y2', type=float)
    pa.add_argument('--apex', type=float, nargs=2, required=True, metavar=('AX','AY'))
    pa.add_argument('--style', default='spine')

    # loop
    pl = sub.add_parser('loop')
    for a in ('src_x','src_y','src_rx','src_ry','dst_x','dst_y','dst_rx','dst_ry'):
        pl.add_argument(a, type=float)
    pl.add_argument('verb')
    pl.add_argument('--via', type=float, nargs=2, required=True, metavar=('VX','VY'))
    pl.add_argument('--via2', type=float, nargs=2, default=None, metavar=('V2X','V2Y'))

    # spine
    ps = sub.add_parser('spine'); ps.add_argument('chain', nargs='+')

    # build — YAML DSL → SVG
    pb = sub.add_parser('build'); pb.add_argument('input'); pb.add_argument('--output', default=None)

    # validate
    pv = sub.add_parser('validate'); pv.add_argument('input'); pv.add_argument('--json', action='store_true', dest='json')

    # geom
    pg = sub.add_parser('geom'); gs = pg.add_subparsers(dest='geom_sub')
    gb = gs.add_parser('boundary')
    for a in ('cx','cy','rx','ry','px','py'): gb.add_argument(a, type=float)
    gb.add_argument('--pad', type=float, default=10)
    gc = gs.add_parser('ctrl')
    for a in ('x1','y1','x2','y2'): gc.add_argument(a, type=float)
    gc.add_argument('--bend', type=float, required=True)
    gm = gs.add_parser('midpoint'); gm.add_argument('curve_type', choices=['quad','cubic'])
    for a in ('x1','y1','cx','cy'): gm.add_argument(a, type=float)
    gm.add_argument('c2x', type=float, nargs='?', default=None); gm.add_argument('c2y', type=float, nargs='?', default=None)
    for a in ('x2','y2'): gm.add_argument(a, type=float)
    gm.set_defaults(c1x=None, c1y=None)
    gi = gs.add_parser('in_ellipse')
    for a in ('px','py','cx','cy','rx','ry'): gi.add_argument(a, type=float)

    # geom anchors — 8 named attachment points for an ellipse
    ga = gs.add_parser('anchors')
    for a in ('cx','cy','rx','ry'): ga.add_argument(a, type=float)
    ga.add_argument('--pad', type=float, default=0,
                    help='Outward offset in px (use 12 for connector attachment)')

    # geom best_anchor — choose best src/dst anchor pair for an edge
    gba = gs.add_parser('best_anchor')
    for a in ('src_cx','src_cy','src_rx','src_ry','dst_cx','dst_cy','dst_rx','dst_ry'):
        gba.add_argument(a, type=float)
    gba.add_argument('--pad', type=float, default=12,
                     help='Outward offset applied to all anchor points (default 12)')

    # geom gap — minimum surface-to-surface gap between two ellipses
    gg = gs.add_parser('gap')
    for a in ('cx1','cy1','rx1','ry1','cx2','cy2','rx2','ry2'): gg.add_argument(a, type=float)

    # geom bearing — bearing-based anchor selection with cardinal bias + bend direction
    gb = gs.add_parser('bearing')
    for a in ('src_cx','src_cy','src_rx','src_ry','dst_cx','dst_cy','dst_rx','dst_ry'):
        gb.add_argument(a, type=float)

    return p


# ---------------------------------------------------------------------------
# geom midpoint arg fixup (cubic needs c1x/c1y = cx/cy, c2x/c2y)
# ---------------------------------------------------------------------------

def cmd_build(args):
    """Read a YAML DSL file and emit a complete systemigram SVG.

    DSL schema (YAML):
      title: str
      subtitle: str          # optional
      canvas:
        width: int           # default 1280
        height: int          # default 900
      nodes:
        <id>:
          label: str         # node title (use \\n for two-line)
          sub: str           # italic sub-mission line (optional)
          children: str      # dot-separated children line (optional)
          domain: green|blue|purple|red|gray|amber
          tier: hero|primary|secondary  # default primary
          rx: int            # ellipse x-radius (default 105)
          ry: int            # ellipse y-radius (default 60)
      edges:
        - from: <node-id>
          verb: str
          to: <node-id>
          category: spine|supp|gov|loop|prevent|anchors
      layout:
        flow: [<node-id>, ...]   # reading order, left→right across canvas
        above: [<node-id>, ...]  # nodes placed above the flow band
        below: [<node-id>, ...]  # nodes placed below the flow band
        flow_y: int              # y-center of flow band (default canvas_height*0.5)
        above_y: int             # y-center of above band (default flow_y - 220)
        below_y: int             # y-center of below band (default flow_y + 220)
    """
    # --- parse YAML (stdlib only: no PyYAML dependency) ---
    # We use a simple line-by-line parser sufficient for this schema.
    try:
        import json as _json  # used for output only
    except ImportError:
        pass

    try:
        # Try stdlib tomllib (Python 3.11+) as a fallback — but YAML ≠ TOML.
        # Instead, use a minimal safe eval approach via ast.
        import ast
        with open(args.input) as f:
            raw = f.read()
    except FileNotFoundError:
        print(f'ERROR: {args.input} not found', file=sys.stderr); return 1

    # Convert YAML to Python dict using a minimal parser
    # Supports: str, int, float, bool, list (inline [a,b,c]), nested dicts
    try:
        spec = _parse_yaml_minimal(raw)
    except Exception as e:
        print(f'ERROR parsing DSL: {e}', file=sys.stderr); return 1

    canvas_w = int(spec.get('canvas', {}).get('width', 1280))
    canvas_h = int(spec.get('canvas', {}).get('height', 900))
    title    = spec.get('title', '')
    subtitle = spec.get('subtitle', '')

    # --- layout: compute node positions ---
    layout     = spec.get('layout', {})
    flow_ids   = layout.get('flow', [])
    above_ids  = layout.get('above', [])
    below_ids  = layout.get('below', [])
    nodes_spec = spec.get('nodes', {})
    edges_spec = spec.get('edges', [])  # needed early for Wave 3 connection anchoring

    def _rx(nid): return int(nodes_spec[nid].get('rx', 105))
    def _ry(nid): return int(nodes_spec[nid].get('ry', 60))

    # ── Wave 0: Diagonal Spine Placement ─────────────────────────────────────
    # The spine flows top-left → bottom-right.
    # Each flow node steps right by (rx[i] + H_GAP + rx[i+1]) and down by V_STEP.
    #
    # H_GAP: horizontal surface-to-surface gap between adjacent spine ellipses.
    #        Must fit a label (≈90px wide) + arrowhead pad (≈22px each side) = ~134px min.
    # V_STEP: vertical drop per spine node. ~80px creates a clear diagonal.
    # TOP_MARGIN / LEFT_MARGIN: position of the first spine node center.
    #        TOP_MARGIN must clear the title (~60px) + subtitle (~20px) + padding = ~120px.

    H_GAP        = int(layout.get('h_gap',       160))
    V_STEP       = int(layout.get('v_step',        80))
    TOP_MARGIN   = int(layout.get('top_margin',   200))  # clears title+subtitle+above-node
    LEFT_MARGIN  = int(layout.get('left_margin',   80))

    # Place spine nodes diagonally: each steps right and down
    positions = {}
    if flow_ids:
        cx = LEFT_MARGIN + _rx(flow_ids[0])
        cy = TOP_MARGIN  + _ry(flow_ids[0])
        for i, nid in enumerate(flow_ids):
            positions[nid] = (round(cx), round(cy))
            if i < len(flow_ids) - 1:
                cx += _rx(flow_ids[i]) + H_GAP + _rx(flow_ids[i + 1])
                cy += V_STEP

    # Spine extents (used to position off-spine bands)
    if flow_ids:
        first_cx, first_cy = positions[flow_ids[0]]
        last_cx,  last_cy  = positions[flow_ids[-1]]
        last_rx = _rx(flow_ids[-1])
        last_ry = _ry(flow_ids[-1])
        spine_x_center = (first_cx + last_cx) / 2
    else:
        first_cx = first_cy = last_cx = last_cy = last_rx = last_ry = 0
        spine_x_center = canvas_w / 2

    # ── Wave 3: Off-spine node placement by connection ───────────────────────
    # Off-spine nodes anchor their x position to the spine node(s) they connect to.
    # This means Context Window sits above Agent Execution (not the spine midpoint)
    # if its primary edge connects to Agent Execution.
    #
    # Algorithm:
    # 1. For each off-spine node, find all spine nodes it connects to (as src or dst).
    # 2. Use the mean x of those spine nodes as the horizontal anchor.
    # 3. If no spine connections, fall back to spine_x_center.
    # 4. y is fixed per band (above_y or below_y) so the band stays at a consistent height.
    # 5. Multiple off-spine nodes in the same band are sorted by their x anchor,
    #    then given a minimum separation of H_GAP to avoid overlap.

    ABOVE_GAP = int(layout.get('above_gap', 120))
    BELOW_GAP = int(layout.get('below_gap', 120))

    _spine_set_w3 = set(flow_ids)

    # Heading clearance
    heading_bottom = 105  # approximate bottom of title + subtitle
    max_above_ry = max((_ry(nid) for nid in above_ids), default=0)

    # MIN_EDGE_CHORD: minimum anchor-to-anchor distance needed to fit a label cleanly.
    # = src_pad(12) + label_height(22) + gap(20) + arrowhead_zone(22) + dst_pad(22) = ~100px
    MIN_EDGE_CHORD = 120

    # above_y: center of above nodes.
    # Must be far enough above any connected spine node to give MIN_EDGE_CHORD clearance.
    # The N-anchor of a spine node at cy is at cy - ry - 22 (dst pad).
    # The S-anchor of an above node at above_y is above_y + above_ry + 12 (src pad).
    # Chord = (cy - ry - 22) - (above_y + above_ry + 12) >= MIN_EDGE_CHORD
    # → above_y <= cy - ry - 22 - above_ry - 12 - MIN_EDGE_CHORD
    # We compute this for each connected spine node and take the minimum (tightest constraint).
    spine_top = first_cy - (_ry(flow_ids[0]) if flow_ids else 0)
    _above_y_candidates = [(heading_bottom + spine_top) // 2]
    for nid in above_ids:
        for e in edges_spec:
            connected_spine = None
            if e.get('from') == nid and e.get('to') in _spine_set_w3:
                connected_spine = e.get('to')
            elif e.get('to') == nid and e.get('from') in _spine_set_w3:
                connected_spine = e.get('from')
            if connected_spine and connected_spine in positions:
                s_cy = positions[connected_spine][1]
                s_ry = _ry(connected_spine)
                max_above_y = s_cy - s_ry - 22 - _ry(nid) - 12 - MIN_EDGE_CHORD
                _above_y_candidates.append(max_above_y)
    above_y = max(heading_bottom + max_above_ry + 15, min(_above_y_candidates))

    # below_y: below the last spine node's bottom edge
    below_y = last_cy + last_ry + BELOW_GAP + max((_ry(nid) for nid in below_ids), default=0)

    def _connection_x_anchor(nid):
        """Return the mean x of spine nodes connected to this off-spine node."""
        connected_xs = []
        for e in edges_spec:
            src, dst = e.get('from'), e.get('to')
            if src == nid and dst in _spine_set_w3 and dst in positions:
                connected_xs.append(positions[dst][0])
            elif dst == nid and src in _spine_set_w3 and src in positions:
                connected_xs.append(positions[src][0])
        if connected_xs:
            return sum(connected_xs) / len(connected_xs)
        return spine_x_center  # fallback: spine midpoint

    def _place_off_spine_band(ids, y):
        """Place off-spine nodes at fixed y, x anchored to their spine connections.

        Nodes are sorted by their natural x anchor, then given minimum H_GAP separation
        to prevent overlap. The group is nudged toward its collective center of gravity.
        """
        if not ids: return {}
        # Compute natural x anchor for each node
        anchors = [(nid, _connection_x_anchor(nid)) for nid in ids]
        # Sort by x anchor
        anchors.sort(key=lambda t: t[1])
        # Assign x positions respecting minimum separation
        result = {}
        if len(anchors) == 1:
            nid, ax = anchors[0]
            result[nid] = (round(ax), round(y))
        else:
            # First pass: use natural anchors
            xs = [ax for _, ax in anchors]
            # Second pass: enforce minimum surface-to-surface gap
            rxs = [_rx(nid) for nid, _ in anchors]
            for i in range(1, len(xs)):
                min_x = xs[i-1] + rxs[i-1] + H_GAP + rxs[i]
                if xs[i] < min_x:
                    xs[i] = min_x
            for i, (nid, _) in enumerate(anchors):
                result[nid] = (round(xs[i]), round(y))
        return result

    positions.update(_place_off_spine_band(above_ids, above_y))
    positions.update(_place_off_spine_band(below_ids, below_y))

    def _place_flat_band(ids, y, center_x):
        """Place nodes horizontally centered at center_x, at fixed y, with H_GAP between them."""
        n = len(ids)
        if n == 0: return {}
        if n == 1:
            return {ids[0]: (round(center_x), round(y))}
        rxs = [_rx(nid) for nid in ids]
        total_w = sum(2 * r for r in rxs) + H_GAP * (n - 1)
        bx = center_x - total_w / 2 + rxs[0]
        result = {}
        for i, nid in enumerate(ids):
            result[nid] = (round(bx), round(y))
            if i < n - 1:
                bx += rxs[i] + H_GAP + rxs[i + 1]
        return result

    # Any unlisted nodes go in a band below the below band, centered on spine
    unlisted = [nid for nid in nodes_spec
                if nid not in flow_ids + above_ids + below_ids]
    unlisted_y = below_y + max((_ry(nid) for nid in below_ids), default=0) + BELOW_GAP
    positions.update(_place_flat_band(unlisted, unlisted_y, spine_x_center))

    # Auto-size canvas to fit all placed nodes (with 80px margin)
    all_xs = [cx + _rx(nid) for nid, (cx, _) in positions.items()]
    all_ys = [cy + _ry(nid) for nid, (_, cy) in positions.items()]
    canvas_w = max(canvas_w, (max(all_xs, default=0) + 80))
    canvas_h = max(canvas_h, (max(all_ys, default=0) + 80))

    # Compute diagram centroid (used for loop bend direction)
    centroid_x = sum(p[0] for p in positions.values()) / max(len(positions), 1)
    centroid_y = sum(p[1] for p in positions.values()) / max(len(positions), 1)

    # Build nodes dict for port_assign: id → (cx, cy, rx, ry)
    pa_nodes = {nid: (positions[nid][0], positions[nid][1], _rx(nid), _ry(nid))
                for nid in nodes_spec if nid in positions}

    # --- edge port assignment ---
    pa_edges = [{'src': e['from'], 'dst': e['to'],
                 'category': e.get('category', 'supp'), 'verb': e.get('verb', ''),
                 **({'anchor_src': e['anchor_src']} if 'anchor_src' in e else {}),
                 **({'anchor_dst': e['anchor_dst']} if 'anchor_dst' in e else {})}
                for e in edges_spec]
    assigned = port_assign(pa_edges, pa_nodes)

    # ── Wave 2: Edge routing evaluation + node nudging ────────────────────────
    # After initial port assignment, check each edge for routing problems.
    # If a curve would pass through a non-terminal node, nudge that node
    # perpendicular to the chord to create clearance, then re-assign.
    # Repeat for up to MAX_RIPPLE passes.
    #
    # Nudge priority: off-spine nodes are nudged before spine nodes.
    # Nudge direction: perpendicular to the problem edge chord, away from diagram centroid.
    # Nudge amount: NUDGE_STEP px per pass.

    MAX_RIPPLE = 3
    NUDGE_STEP = 60   # px per ripple pass

    # Categorise nodes by nudgeability (off-spine nodes nudge freely; spine nodes only if needed)
    _spine_set  = set(flow_ids)
    _above_set  = set(above_ids)
    _below_set  = set(below_ids)

    def _nudge_priority(nid):
        """Lower = easier to nudge. Off-spine nodes nudge first."""
        if nid in _above_set or nid in _below_set: return 0
        if nid in _spine_set: return 2
        return 1  # unlisted

    def _check_edge_clips(ae, pos_snap):
        """Return the id of the first intermediate node the edge clips, or None."""
        sx, sy = ae['src_pt']; dx, dy = ae['dst_pt']
        src_e = (pos_snap[ae['src']][0], pos_snap[ae['src']][1], _rx(ae['src']), _ry(ae['src']))
        dst_e = (pos_snap[ae['dst']][0], pos_snap[ae['dst']][1], _rx(ae['dst']), _ry(ae['dst']))
        # Quick route: straight-line midpoint check
        for nid, (cx2, cy2) in pos_snap.items():
            if nid == ae['src'] or nid == ae['dst']: continue
            e = (cx2, cy2, _rx(nid), _ry(nid))
            if e == src_e or e == dst_e: continue
            # Sample a few points along the chord
            for t in (0.25, 0.5, 0.75):
                px2 = sx + t*(dx-sx); py2 = sy + t*(dy-sy)
                if in_ellipse(px2, py2, *e, pad=16):
                    return nid
        return None

    for _ripple in range(MAX_RIPPLE):
        _any_nudge = False
        # Re-build pa_nodes with current positions for re-check
        _snap = {nid: (positions[nid][0], positions[nid][1], _rx(nid), _ry(nid))
                 for nid in nodes_spec if nid in positions}
        # Re-run port_assign with current positions
        _pa_nodes_cur = {nid: _snap[nid] for nid in _snap}
        _assigned_cur = port_assign(pa_edges, _pa_nodes_cur)

        for ae in _assigned_cur:
            blocker = _check_edge_clips(ae, {nid: (positions[nid][0], positions[nid][1])
                                              for nid in positions})
            if blocker is None:
                continue
            # Nudge the blocker node perpendicular to the edge chord, away from centroid
            sx0, sy0 = ae['src_pt']; dx0, dy0 = ae['dst_pt']
            chord_dx = dx0 - sx0; chord_dy = dy0 - sy0
            chord_len = math.hypot(chord_dx, chord_dy)
            if chord_len < 1: continue
            # Two perpendicular options
            perp1 = (-chord_dy/chord_len, chord_dx/chord_len)
            perp2 = ( chord_dy/chord_len, -chord_dx/chord_len)
            bx, by = positions[blocker]
            # Pick direction away from centroid
            d1 = math.hypot(bx + perp1[0]*NUDGE_STEP - centroid_x,
                             by + perp1[1]*NUDGE_STEP - centroid_y)
            d2 = math.hypot(bx + perp2[0]*NUDGE_STEP - centroid_x,
                             by + perp2[1]*NUDGE_STEP - centroid_y)
            perp = perp1 if d1 >= d2 else perp2
            new_bx = round(bx + perp[0] * NUDGE_STEP)
            new_by = round(by + perp[1] * NUDGE_STEP)
            # Only nudge if it stays on canvas
            if (0 < new_bx < canvas_w) and (0 < new_by < canvas_h):
                positions[blocker] = (new_bx, new_by)
                _any_nudge = True

        if not _any_nudge:
            break  # converged — no more nudging needed

    # Final port assignment with nudged positions
    pa_nodes = {nid: (positions[nid][0], positions[nid][1], _rx(nid), _ry(nid))
                for nid in nodes_spec if nid in positions}
    assigned = port_assign(pa_edges, pa_nodes)

    # Recompute centroid after nudging (positions may have shifted)
    centroid_x = sum(p[0] for p in positions.values()) / max(len(positions), 1)
    centroid_y = sum(p[1] for p in positions.values()) / max(len(positions), 1)

    # Re-sync all_ellipses after nudging (used by _safe_bend and _label_overlaps)
    # This is done lazily just before the draw loop below.

    # --- emit SVG ---
    lines = []
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {canvas_w} {canvas_h}" '
                 f'width="{canvas_w}" height="{canvas_h}">')
    lines.append(SVG_DEFS)
    # Title
    ty = 46
    if title:
        lines.append(f'  <text x="{canvas_w//2}" y="{ty}" text-anchor="middle" '
                     f'font-size="20" font-weight="700" fill="#172B4D" letter-spacing="0.5">{title}</text>')
        ty += 24
    if subtitle:
        lines.append(f'  <text x="{canvas_w//2}" y="{ty}" text-anchor="middle" '
                     f'font-size="13" fill="#6B778C" font-style="italic">{subtitle}</text>')

    # All node ellipses for intersection checking (built AFTER Wave 2 nudging)
    all_ellipses = [(positions[nid][0], positions[nid][1], _rx(nid), _ry(nid))
                    for nid in nodes_spec if nid in positions]

    def _label_overlaps(mx, my, lw, src_e, dst_e):
        """Check if a label rect (centered at mx,my, width lw, height 22) overlaps any non-terminal node."""
        lh = 22
        corners = [(mx - lw/2, my - lh/2), (mx + lw/2, my - lh/2),
                   (mx - lw/2, my + lh/2), (mx + lw/2, my + lh/2), (mx, my)]
        for e in all_ellipses:
            if e == src_e or e == dst_e: continue
            if any(in_ellipse(cx, cy, *e) for cx, cy in corners):
                return True
        return False

    def _safe_bend(sx, sy, dx, dy, bend_mag, src_id, dst_id):
        """Auto-increase bend until the curve and its label are outside all non-terminal nodes."""
        src_e = (positions[src_id][0], positions[src_id][1], _rx(src_id), _ry(src_id))
        dst_e = (positions[dst_id][0], positions[dst_id][1], _rx(dst_id), _ry(dst_id))
        verb = next((ae['verb'] for ae in assigned if ae['src'] == src_id and ae['dst'] == dst_id), '')
        lw = label_rect_width(verb)
        sign = 1 if bend_mag >= 0 else -1
        mag = abs(bend_mag)
        for _ in range(32):  # max 32 iterations
            ctrl = quad_ctrl(sx, sy, dx, dy, sign * mag)
            mx, my = quad_mid(sx, sy, ctrl[0], ctrl[1], dx, dy)
            # Sample curve densely including very near endpoints
            _t_vals = (0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45,
                       0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95)
            samples = []
            for t in _t_vals:
                u = 1 - t
                qx = u*u*sx + 2*u*t*ctrl[0] + t*t*dx
                qy = u*u*sy + 2*u*t*ctrl[1] + t*t*dy
                samples.append((t, qx, qy))
            # Check curve samples against all non-terminal nodes.
            # We exclude both src and dst from the check — the port anchors (pad=22)
            # ensure the curve starts and ends outside those nodes. We only need to
            # ensure the curve doesn't pass through any INTERMEDIATE node.
            bad = any(in_ellipse(px, py, *e, pad=8)
                      for _, px, py in samples
                      for e in all_ellipses
                      if e != src_e and e != dst_e)
            if not bad:
                bad = _label_overlaps(mx, my, lw, src_e, dst_e)
            if not bad:
                return sign * mag, ctrl, (mx, my)
            mag += 0.08  # increase bend and retry
        return sign * mag, ctrl, (mx, my)

    # Edges (drawn first)
    for ae in assigned:
        cat   = CATEGORY.get(ae['category'], CATEGORY['supp'])
        src_n = nodes_spec[ae['src']]
        dst_n = nodes_spec[ae['dst']]
        # Color: use src domain color unless category forces one
        color_domain = cat['force_color'] or src_n.get('domain', 'gray')
        dom = DOMAIN[color_domain]
        sw  = cat['width']
        # ALL edges bend AWAY from diagram centroid (outward rule).
        # This implements "anti-clockwise, curve toward outside":
        #   - compute chord midpoint
        #   - find direction from centroid to chord midpoint (= outward)
        #   - cross product with chord direction gives which side is outward
        #   - always bend toward that side
        #
        # Special case for loop edges: the chord often passes near/through the centroid,
        # making the cross product unreliable. For loops, we instead pick the canvas
        # boundary that gives the widest clear arc — biased toward the top of the canvas
        # for edges going right→left (return paths), or whichever perpendicular direction
        # points away from the bulk of the diagram.
        sx0, sy0 = ae['src_pt']
        dx0, dy0 = ae['dst_pt']
        mid_x = (sx0 + dx0) / 2
        mid_y = (sy0 + dy0) / 2
        chord_dx = dx0 - sx0
        chord_dy = dy0 - sy0
        chord_len = math.hypot(chord_dx, chord_dy)

        if ae['category'] == 'loop':
            # For loop/feedback edges: pick the bend direction that moves the
            # control point furthest from the centroid while staying on canvas.
            b = cat['bend']
            ctrl_pos = quad_ctrl(sx0, sy0, dx0, dy0, +b)
            ctrl_neg = quad_ctrl(sx0, sy0, dx0, dy0, -b)
            pos_on_canvas = 0 < ctrl_pos[0] < canvas_w and 0 < ctrl_pos[1] < canvas_h
            neg_on_canvas = 0 < ctrl_neg[0] < canvas_w and 0 < ctrl_neg[1] < canvas_h
            dist_pos = math.hypot(ctrl_pos[0] - centroid_x, ctrl_pos[1] - centroid_y)
            dist_neg = math.hypot(ctrl_neg[0] - centroid_x, ctrl_neg[1] - centroid_y)
            if pos_on_canvas and neg_on_canvas:
                bend_sign_override = +1 if dist_pos >= dist_neg else -1
            elif pos_on_canvas:
                bend_sign_override = +1
            elif neg_on_canvas:
                bend_sign_override = -1
            else:
                bend_sign_override = ae['bend_sign']
        else:
            # Curve direction rule: follows the Y-component of travel.
            #   - chord going downward (dy > 0): curve bows DOWN  (bend_sign = +1)
            #   - chord going upward   (dy < 0): curve bows UP    (bend_sign = -1)
            #   - chord nearly flat (|dy| < threshold): bow away from centroid
            #
            # This gives: Plan→AgentExec (SE) bows south ✓
            #             contextwindow→developer (going up+left) bows north ✓
            #             flat spine edges bow in a consistent direction.
            #
            # The perpendicular convention in quad_ctrl:
            #   bend > 0 → control point pushed LEFT of the chord direction
            #   bend < 0 → control point pushed RIGHT of the chord direction
            # For a chord going RIGHT (+x), left-of-chord = UP (negative y) = upward bow.
            # For a chord going RIGHT+DOWN (SE), left-of-chord = toward NE = upward bow. WRONG.
            # We want downward bow for SE, so we need +bend (right-of-chord for SE).
            # Right-of-chord for SE is toward SW → downward. ✓
            #
            # General: we want the perpendicular pointing in the same Y direction as dy.
            # quad_ctrl uses the perpendicular (-dy/L, dx/L) for positive bend.
            # The Y-component of this perpendicular is dx/L.
            # We want this Y-component to match sign(dy):
            #   sign(dx/L) should equal sign(dy)  → sign(dx) == sign(dy) → bend = +1
            #   otherwise bend = -1
            # For flat chords (|dy| small), fall back to centroid-outward.
            # Curve direction rule: the curve bows in the same direction as the
            # dominant axis of travel. For spine edges (SE anchors), this means
            # all right+down edges bow downward consistently.
            #
            # The perpendicular in quad_ctrl for +bend is (-dy/L, dx/L).
            # Its Y component is dx/L. We want the curve to bow downward when
            # chord_dy > 0, so we need the Y component of the perpendicular to
            # be positive (downward in SVG). That means dx/L > 0, i.e. dx > 0.
            # When both dx and dy have the same sign → bend = +1 bows the right way.
            # When they differ → bend = -1.
            #
            # Special case: truly flat edges (dy == 0) use centroid-outward.
            if chord_dy == 0:
                # Exactly flat: use centroid-outward
                out_dx = mid_x - centroid_x
                out_dy = mid_y - centroid_y
                cross = chord_dx * out_dy - chord_dy * out_dx
                bend_sign_override = 1 if cross >= 0 else -1
            else:
                # Y-component of perpendicular (-dy/L, dx/L) is dx/L.
                # We want it to match sign(chord_dy) so the curve bows
                # in the direction of travel.
                if (chord_dx >= 0) == (chord_dy >= 0):
                    bend_sign_override = +1
                else:
                    bend_sign_override = -1

        # Curve magnitude: proportional to chord length.
        # Short edges are nearly straight; long edges have more visible curvature.
        # Base magnitude from category, scaled by chord length.
        chord_len_actual = math.hypot(dx0 - sx0, dy0 - sy0)
        if ae['category'] == 'loop':
            dynamic_bend_mag = cat['bend']  # loops keep their fixed large bend
        else:
            # Scale: 0.05 for chord<150, up to cat['bend'] for chord>500
            min_bend = 0.04
            max_bend = cat['bend']
            # Sigmoid-ish scale: clamp chord to [100, 500] range
            t_chord = max(0.0, min(1.0, (chord_len_actual - 150) / 350))
            dynamic_bend_mag = min_bend + t_chord * (max_bend - min_bend)

        bend_mag = dynamic_bend_mag * bend_sign_override
        sx, sy = ae['src_pt']
        dx, dy = ae['dst_pt']
        # Compute ctrl point with auto-bend to avoid node intersections
        bend_mag, ctrl, (mx, my) = _safe_bend(sx, sy, dx, dy, bend_mag, ae['src'], ae['dst'])
        lw = label_rect_width(ae['verb'])
        # Rule C: label box must not overlap arrowhead zone.
        # Strategy 1: slide label to t=0.35 (toward source) if that clears it.
        # Strategy 2: if edge is too short for Strategy 1, offset label perpendicular
        #             to the chord (to the side), away from diagram centroid.
        lh = 22
        def _arrowhead_in_label(lx, ly):
            return ((lx - lw/2 - 20) < dx < (lx + lw/2 + 20) and
                    (ly - lh/2 - 20) < dy < (ly + lh/2 + 20))

        if _arrowhead_in_label(mx, my):
            # Strategy 1: slide to t=0.35
            t = 0.35; u = 1 - t
            mx2 = u*u*sx + 2*u*t*ctrl[0] + t*t*dx
            my2 = u*u*sy + 2*u*t*ctrl[1] + t*t*dy
            if not _arrowhead_in_label(mx2, my2):
                mx, my = mx2, my2
            else:
                # Strategy 2: offset perpendicular to chord, away from centroid
                chord_dx2 = dx - sx; chord_dy2 = dy - sy
                chord_len2 = math.hypot(chord_dx2, chord_dy2)
                if chord_len2 > 1e-6:
                    perp_x = -chord_dy2 / chord_len2
                    perp_y =  chord_dx2 / chord_len2
                    # Pick the perpendicular direction away from centroid
                    d1 = math.hypot(mx + perp_x*50 - centroid_x, my + perp_y*50 - centroid_y)
                    d2 = math.hypot(mx - perp_x*50 - centroid_x, my - perp_y*50 - centroid_y)
                    sign2 = 1 if d1 >= d2 else -1
                    mx = mx + sign2 * perp_x * 50
                    my = my + sign2 * perp_y * 50
        dash_attr = f' stroke-dasharray="{cat["dash"]}"' if cat['dash'] else ''
        lines.append(f'  <path d="M {sx},{sy} Q {ctrl[0]},{ctrl[1]} {dx},{dy}"')
        lines.append(f'        stroke="{dom["stroke"]}" stroke-width="{sw}"'
                     f' fill="none" marker-end="url(#{dom["arrow"]})"'
                     f'{dash_attr}/>')
        lines.append(f'  <rect x="{mx-lw/2:.0f}" y="{my-11:.0f}" width="{lw}" height="22"'
                     f' rx="3" fill="white" stroke="{dom["stroke"]}" stroke-width="1"/>')
        lines.append(f'  <text x="{mx:.0f}" y="{my+4:.0f}" text-anchor="middle"'
                     f' font-size="12" font-weight="600" fill="{dom["stroke"]}">{ae["verb"]}</text>')

    # Nodes (drawn on top)
    for nid, ns in nodes_spec.items():
        if nid not in positions: continue
        cx, cy = positions[nid]
        rx = _rx(nid); ry = _ry(nid)
        tier_key = ns.get('tier', 'primary')
        tier = TIER.get(tier_key, TIER['primary'])
        dom  = DOMAIN[ns.get('domain', 'gray')]
        tsz  = tier['title_size']
        tw   = tier['title_weight']
        stw  = tier['stroke_width']
        lines.append(f'  <ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}"')
        lines.append(f'           fill="url(#{dom["grad"]})" stroke="{dom["stroke"]}"'
                     f' stroke-width="{stw}" filter="url(#sh)"/>')
        label = ns.get('label', nid)
        label_lines = label.split('\\n')
        n_lines = len(label_lines) + (1 if ns.get('sub') else 0) + (1 if ns.get('children') else 0)
        # Vertical centering: space lines ~18px apart, center on cy
        total_h = (n_lines - 1) * 18
        text_y = cy - total_h // 2
        for i, ll in enumerate(label_lines):
            lines.append(f'  <text x="{cx}" y="{text_y + i*18}" text-anchor="middle"'
                         f' font-size="{tsz}" font-weight="{tw}" fill="{dom["text"]}">{ll}</text>')
        off = len(label_lines) * 18
        if ns.get('sub'):
            lines.append(f'  <text x="{cx}" y="{text_y + off}" text-anchor="middle"'
                         f' font-size="12" font-style="italic" fill="{dom["text"]}">{ns["sub"]}</text>')
            off += 18
        if ns.get('children'):
            lines.append(f'  <text x="{cx}" y="{text_y + off}" text-anchor="middle"'
                         f' font-size="12" fill="{dom["text"]}">{ns["children"]}</text>')

    # Spine caption
    flow_labels = [nodes_spec[nid].get('label', nid).replace('\\n', ' ') for nid in flow_ids]
    verbs_on_spine = [ae['verb'] for ae in assigned if ae['category'] == 'spine']
    caption_parts = []
    for i, lbl in enumerate(flow_labels):
        caption_parts.append(lbl)
        if i < len(verbs_on_spine):
            caption_parts.append(f'› {verbs_on_spine[i]} ›')
    caption = '  '.join(caption_parts)
    lines.append(f'  <text x="{canvas_w//2}" y="{canvas_h - 38}" text-anchor="middle"'
                 f' font-size="12" fill="#97A0AF" letter-spacing="1">— SPINE: {caption} —</text>')

    lines.append('</svg>')
    svg = '\n'.join(lines)

    out = getattr(args, 'output', None) or args.input.replace('.yml', '.svg').replace('.yaml', '.svg')
    with open(out, 'w') as f:
        f.write(svg)
    print(f'Wrote {out} ({canvas_w}×{canvas_h})')


def _parse_yaml_minimal(text):
    """Minimal YAML parser supporting the systemigram DSL schema.

    Handles: scalars, quoted strings, int/float, bool, inline lists,
    nested dicts via indentation, list-of-dicts (- key: val).
    No anchors, no multi-line strings, no complex types.
    """
    import re as _re

    def _cast(v):
        v = v.strip().strip('"').strip("'")
        if v.lower() in ('true', 'yes'): return True
        if v.lower() in ('false', 'no'): return False
        try: return int(v)
        except ValueError: pass
        try: return float(v)
        except ValueError: pass
        return v

    def _parse_inline_list(s):
        s = s.strip()
        if s.startswith('[') and s.endswith(']'):
            inner = s[1:-1]
            return [_cast(x) for x in _re.split(r',\s*', inner) if x.strip()]
        return [_cast(s)]

    lines = text.splitlines()
    # Strip comments
    lines = [_re.sub(r'\s*#.*$', '', l) for l in lines]

    def _parse_block(lines, base_indent):
        """Recursively parse a YAML block at base_indent level."""
        result = None  # will become dict or list
        i = 0
        while i < len(lines):
            line = lines[i]
            if not line.strip():
                i += 1; continue
            indent = len(line) - len(line.lstrip())
            if indent < base_indent:
                break
            stripped = line.strip()

            # List item
            if stripped.startswith('- '):
                if result is None: result = []
                rest = stripped[2:].strip()
                if ':' in rest:
                    # Inline dict item: "- key: val"
                    k, v = rest.split(':', 1)
                    item = {k.strip(): _cast(v) if v.strip() else None}
                    # Look ahead for more k: v lines at indent+2
                    j = i + 1
                    sub_lines = []
                    while j < len(lines):
                        if not lines[j].strip(): j += 1; continue
                        sub_ind = len(lines[j]) - len(lines[j].lstrip())
                        if sub_ind <= indent: break
                        sub_lines.append(lines[j]); j += 1
                    if sub_lines:
                        sub = _parse_block(sub_lines, indent + 2)
                        if isinstance(sub, dict): item.update(sub)
                    result.append(item); i = j; continue
                else:
                    result.append(_cast(rest)); i += 1; continue

            # Key: value pair
            if ':' in stripped:
                k, v = stripped.split(':', 1)
                k = k.strip(); v = v.strip()
                if result is None: result = {}
                if v == '' or v is None:
                    # Value is a nested block — collect child lines
                    j = i + 1
                    child_lines = []
                    while j < len(lines):
                        if not lines[j].strip(): j += 1; continue
                        child_indent = len(lines[j]) - len(lines[j].lstrip())
                        if child_indent <= indent: break
                        child_lines.append(lines[j]); j += 1
                    result[k] = _parse_block(child_lines, indent + 2) if child_lines else None
                    i = j; continue
                elif v.startswith('['):
                    result[k] = _parse_inline_list(v)
                else:
                    result[k] = _cast(v)
            i += 1
        return result if result is not None else {}

    return _parse_block(lines, 0)


def _fixup_geom_midpoint(args):
    """For 'geom midpoint cubic', cx/cy are c1x/c1y; c2x/c2y are the second ctrl pts."""
    if getattr(args, 'geom_sub', None) == 'midpoint' and getattr(args, 'curve_type', None) == 'cubic':
        args.c1x = args.cx
        args.c1y = args.cy
        if args.c2x is None or args.c2y is None:
            print('ERROR: cubic midpoint requires c2x c2y x2 y2 after c1x c1y.', file=sys.stderr)
            sys.exit(1)


# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------

def main():
    parser = build_parser()
    args = parser.parse_args()

    # Handle --agent-help at top level (before command dispatch)
    if args.agent_help is not None:
        if args.agent_help == '__tier1__':
            print(AGENT_HELP_TIER1, end='')
        else:
            cmd_key = args.agent_help
            if cmd_key in AGENT_HELP_TIER2:
                print(AGENT_HELP_TIER2[cmd_key], end='')
            else:
                print(f'No tier-2 help for "{cmd_key}". Known commands: {", ".join(AGENT_HELP_TIER2)}',
                      file=sys.stderr)
                sys.exit(1)
        return

    if args.command is None:
        parser.print_help()
        sys.exit(0)

    # Subcommand dispatch
    if args.command == 'init':
        cmd_init(args)
    elif args.command == 'node':
        cmd_node(args)
    elif args.command == 'edge':
        cmd_edge(args)
    elif args.command == 'geom':
        if not hasattr(args, 'geom_sub') or args.geom_sub is None:
            print('ERROR: geom requires a subcommand: anchors|best_anchor|gap|boundary|ctrl|midpoint|in_ellipse',
                  file=sys.stderr)
            sys.exit(1)
        _fixup_geom_midpoint(args)
        cmd_geom(args)
    elif args.command == 'arrow':
        cmd_arrow(args)
    elif args.command == 'loop':
        cmd_loop(args)
    elif args.command == 'spine':
        cmd_spine(args)
    elif args.command == 'validate':
        cmd_validate(args)
    elif args.command == 'build':
        cmd_build(args)
    else:
        print(f'ERROR: unknown command "{args.command}".', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

