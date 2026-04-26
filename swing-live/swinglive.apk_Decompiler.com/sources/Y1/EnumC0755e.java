package y1;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: y1.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0755e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0592H f6846a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0755e f6847b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0755e f6848c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0755e f6849d;
    public static final EnumC0755e e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final EnumC0755e f6850f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final EnumC0755e f6851m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ EnumC0755e[] f6852n;

    static {
        EnumC0755e enumC0755e = new EnumC0755e("ENDPOINT_MALFORMED", 0);
        f6847b = enumC0755e;
        EnumC0755e enumC0755e2 = new EnumC0755e("TIMEOUT", 1);
        f6848c = enumC0755e2;
        EnumC0755e enumC0755e3 = new EnumC0755e("REFUSED", 2);
        f6849d = enumC0755e3;
        EnumC0755e enumC0755e4 = new EnumC0755e("CLOSED_BY_SERVER", 3);
        e = enumC0755e4;
        EnumC0755e enumC0755e5 = new EnumC0755e("NO_INTERNET", 4);
        f6850f = enumC0755e5;
        EnumC0755e enumC0755e6 = new EnumC0755e("UNKNOWN", 5);
        f6851m = enumC0755e6;
        EnumC0755e[] enumC0755eArr = {enumC0755e, enumC0755e2, enumC0755e3, enumC0755e4, enumC0755e5, enumC0755e6};
        f6852n = enumC0755eArr;
        H0.a.z(enumC0755eArr);
        f6846a = new C0592H();
    }

    public static EnumC0755e valueOf(String str) {
        return (EnumC0755e) Enum.valueOf(EnumC0755e.class, str);
    }

    public static EnumC0755e[] values() {
        return (EnumC0755e[]) f6852n.clone();
    }
}
