package l3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class M {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final X.N f5665b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final M f5666c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final M f5667d;
    public static final M e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ M[] f5668f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5669a;

    static {
        M m4 = new M("PLATFORM_ENCODED", 0, 0);
        f5666c = m4;
        M m5 = new M("JSON_ENCODED", 1, 1);
        f5667d = m5;
        M m6 = new M("UNEXPECTED_STRING", 2, 2);
        e = m6;
        M[] mArr = {m4, m5, m6};
        f5668f = mArr;
        H0.a.z(mArr);
        f5665b = new X.N(23);
    }

    public M(String str, int i4, int i5) {
        this.f5669a = i5;
    }

    public static M valueOf(String str) {
        return (M) Enum.valueOf(M.class, str);
    }

    public static M[] values() {
        return (M[]) f5668f.clone();
    }
}
