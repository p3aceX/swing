package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: o3.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0604l {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0604l f6113b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0604l f6114c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0604l[] f6115d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6116a;

    static {
        EnumC0604l enumC0604l = new EnumC0604l("ECDHE", 0, "ECDHE_ECDSA");
        f6113b = enumC0604l;
        EnumC0604l enumC0604l2 = new EnumC0604l("RSA", 1, "RSA");
        f6114c = enumC0604l2;
        EnumC0604l[] enumC0604lArr = {enumC0604l, enumC0604l2};
        f6115d = enumC0604lArr;
        H0.a.z(enumC0604lArr);
    }

    public EnumC0604l(String str, int i4, String str2) {
        this.f6116a = str2;
    }

    public static EnumC0604l valueOf(String str) {
        return (EnumC0604l) Enum.valueOf(EnumC0604l.class, str);
    }

    public static EnumC0604l[] values() {
        return (EnumC0604l[]) f6115d.clone();
    }
}
