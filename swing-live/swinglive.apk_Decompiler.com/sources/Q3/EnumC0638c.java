package q3;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: q3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0638c {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0592H f6280c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0638c f6281d;
    public static final EnumC0638c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ EnumC0638c[] f6282f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6283m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final short f6284a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6285b;

    static {
        EnumC0638c enumC0638c = new EnumC0638c("sect163k1", 0, (short) 1, 163);
        EnumC0638c enumC0638c2 = new EnumC0638c("sect163r1", 1, (short) 2, 163);
        EnumC0638c enumC0638c3 = new EnumC0638c("sect163r2", 2, (short) 3, 163);
        EnumC0638c enumC0638c4 = new EnumC0638c("sect193r1", 3, (short) 4, 193);
        EnumC0638c enumC0638c5 = new EnumC0638c("sect193r2", 4, (short) 5, 193);
        EnumC0638c enumC0638c6 = new EnumC0638c("sect233k1", 5, (short) 6, 233);
        EnumC0638c enumC0638c7 = new EnumC0638c("sect233r1", 6, (short) 7, 233);
        EnumC0638c enumC0638c8 = new EnumC0638c("sect239k1", 7, (short) 8, 239);
        EnumC0638c enumC0638c9 = new EnumC0638c("sect283k1", 8, (short) 9, 283);
        EnumC0638c enumC0638c10 = new EnumC0638c("sect283r1", 9, (short) 10, 283);
        EnumC0638c enumC0638c11 = new EnumC0638c("sect409k1", 10, (short) 11, 409);
        EnumC0638c enumC0638c12 = new EnumC0638c("sect409r1", 11, (short) 12, 409);
        EnumC0638c enumC0638c13 = new EnumC0638c("sect571k1", 12, (short) 13, 571);
        EnumC0638c enumC0638c14 = new EnumC0638c("sect571r1", 13, (short) 14, 571);
        EnumC0638c enumC0638c15 = new EnumC0638c("secp160k1", 14, (short) 15, 160);
        EnumC0638c enumC0638c16 = new EnumC0638c("secp160r1", 15, (short) 16, 160);
        EnumC0638c enumC0638c17 = new EnumC0638c("secp160r2", 16, (short) 17, 160);
        EnumC0638c enumC0638c18 = new EnumC0638c("secp192k1", 17, (short) 18, 192);
        EnumC0638c enumC0638c19 = new EnumC0638c("secp192r1", 18, (short) 19, 192);
        EnumC0638c enumC0638c20 = new EnumC0638c("secp224k1", 19, (short) 20, 224);
        EnumC0638c enumC0638c21 = new EnumC0638c("secp224r1", 20, (short) 21, 224);
        EnumC0638c enumC0638c22 = new EnumC0638c("secp256k1", 21, (short) 22, 256);
        EnumC0638c enumC0638c23 = new EnumC0638c("secp256r1", 22, (short) 23, 256);
        f6281d = enumC0638c23;
        EnumC0638c enumC0638c24 = new EnumC0638c("secp384r1", 23, (short) 24, 384);
        e = enumC0638c24;
        EnumC0638c[] enumC0638cArr = {enumC0638c, enumC0638c2, enumC0638c3, enumC0638c4, enumC0638c5, enumC0638c6, enumC0638c7, enumC0638c8, enumC0638c9, enumC0638c10, enumC0638c11, enumC0638c12, enumC0638c13, enumC0638c14, enumC0638c15, enumC0638c16, enumC0638c17, enumC0638c18, enumC0638c19, enumC0638c20, enumC0638c21, enumC0638c22, enumC0638c23, enumC0638c24, new EnumC0638c("secp521r1", 24, (short) 25, 521)};
        f6282f = enumC0638cArr;
        f6283m = H0.a.z(enumC0638cArr);
        f6280c = new C0592H();
    }

    public EnumC0638c(String str, int i4, short s4, int i5) {
        this.f6284a = s4;
        this.f6285b = i5;
    }

    public static EnumC0638c valueOf(String str) {
        return (EnumC0638c) Enum.valueOf(EnumC0638c.class, str);
    }

    public static EnumC0638c[] values() {
        return (EnumC0638c[]) f6282f.clone();
    }
}
