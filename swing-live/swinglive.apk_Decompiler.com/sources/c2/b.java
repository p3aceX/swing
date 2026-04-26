package c2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ b[] f3297a;

    static {
        b[] bVarArr = {new b("SORENSON_H263", 0), new b("SCREEN_1", 1), new b("VP6", 2), new b("VP6_ALPHA", 3), new b("SCREEN_2", 4), new b("AVC", 5), new b("UNKNOWN", 6), new b("HEVC", 7), new b("AV1", 8), new b("VP9", 9), new b("VP8", 10), new b("AVC_CC", 11)};
        f3297a = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f3297a.clone();
    }
}
