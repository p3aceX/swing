package q3;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: q3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0636a {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0592H f6267d;
    public static final EnumC0636a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final EnumC0636a f6268f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final EnumC0636a f6269m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final EnumC0636a f6270n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ EnumC0636a[] f6271o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6272p;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f6273a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6274b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6275c;

    static {
        EnumC0636a enumC0636a = new EnumC0636a("NONE", 0, (byte) 0, "", "");
        EnumC0636a enumC0636a2 = new EnumC0636a("MD5", 1, (byte) 1, "MD5", "HmacMD5");
        EnumC0636a enumC0636a3 = new EnumC0636a("SHA1", 2, (byte) 2, "SHA-1", "HmacSHA1");
        e = enumC0636a3;
        EnumC0636a enumC0636a4 = new EnumC0636a("SHA224", 3, (byte) 3, "SHA-224", "HmacSHA224");
        EnumC0636a enumC0636a5 = new EnumC0636a("SHA256", 4, (byte) 4, "SHA-256", "HmacSHA256");
        f6268f = enumC0636a5;
        EnumC0636a enumC0636a6 = new EnumC0636a("SHA384", 5, (byte) 5, "SHA-384", "HmacSHA384");
        f6269m = enumC0636a6;
        EnumC0636a enumC0636a7 = new EnumC0636a("SHA512", 6, (byte) 6, "SHA-512", "HmacSHA512");
        f6270n = enumC0636a7;
        EnumC0636a[] enumC0636aArr = {enumC0636a, enumC0636a2, enumC0636a3, enumC0636a4, enumC0636a5, enumC0636a6, enumC0636a7, new EnumC0636a("INTRINSIC", 7, (byte) 8, "INTRINSIC", "Intrinsic")};
        f6271o = enumC0636aArr;
        f6272p = H0.a.z(enumC0636aArr);
        f6267d = new C0592H();
    }

    public EnumC0636a(String str, int i4, byte b5, String str2, String str3) {
        this.f6273a = b5;
        this.f6274b = str2;
        this.f6275c = str3;
    }

    public static EnumC0636a valueOf(String str) {
        return (EnumC0636a) Enum.valueOf(EnumC0636a.class, str);
    }

    public static EnumC0636a[] values() {
        return (EnumC0636a[]) f6271o.clone();
    }
}
