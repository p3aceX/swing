package a2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ e[] f2641a;

    static {
        e[] eVarArr = {new e("SR_5_5K", 0, 0), new e("SR_11K", 1, 1), new e("SR_22K", 2, 2), new e("SR_44_1K", 3, 3)};
        f2641a = eVarArr;
        H0.a.z(eVarArr);
    }

    public e(String str, int i4, int i5) {
    }

    public static e valueOf(String str) {
        return (e) Enum.valueOf(e.class, str);
    }

    public static e[] values() {
        return (e[]) f2641a.clone();
    }
}
