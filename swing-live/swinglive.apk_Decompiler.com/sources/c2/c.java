package c2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ c[] f3298a;

    static {
        c[] cVarArr = {new c("SEQUENCE_START", 0), new c("CODED_FRAMES", 1), new c("SEQUENCE_END", 2), new c("CODED_FRAMES_X", 3), new c("METADATA", 4), new c("MPEG_2_TS_SEQUENCE_START", 5), new c("MULTITRACK", 6), new c("MOD_EX", 7)};
        f3298a = cVarArr;
        H0.a.z(cVarArr);
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f3298a.clone();
    }
}
