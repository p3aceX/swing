package a2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ b[] f2634a;

    static {
        b[] bVarArr = {new b("SEQUENCE_START", 0), new b("CODED_FRAMES", 1), new b("SEQUENCE_END", 2), new b("CODED_FRAMES_X", 3), new b("METADATA", 4), new b("MULTITRACK", 5), new b("RESERVED", 6), new b("MOD_EX", 7)};
        f2634a = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f2634a.clone();
    }
}
