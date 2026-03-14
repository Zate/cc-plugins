# CWE-502: Unsafe Deserialization — Triage Criteria

## TRUE_POSITIVE when:
- pickle.loads() or pickle.load() with data from untrusted source
- yaml.load() without Loader=SafeLoader (Python)
- Java ObjectInputStream.readObject() on untrusted input
- PHP unserialize() on user input
- Marshal.load() in Ruby on untrusted data
- JSON.parse() is generally safe but check if result feeds eval()

## FALSE_POSITIVE when:
- Data source is trusted (local file written by same application, internal cache)
- yaml.safe_load() or yaml.load(Loader=SafeLoader) used
- pickle used only for local caching with no external input
- Deserialization of data that was serialized by the same application with integrity checks
- Test files deserializing test fixtures

## SEVERITY adjustment:
- CRITICAL: Untrusted network input deserialized (HTTP body, message queue)
- HIGH: File upload content deserialized
- MEDIUM: Local file deserialized but file permissions not verified
- LOW: Internal cache deserialization
