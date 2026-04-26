package q3;

import o3.C0592H;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: q3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0642g {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6292b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0642g f6293c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0642g f6294d;
    public static final /* synthetic */ EnumC0642g[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6295f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f6296a;

    static {
        EnumC0642g enumC0642g = new EnumC0642g("ANON", 0, (byte) 0);
        EnumC0642g enumC0642g2 = new EnumC0642g("RSA", 1, (byte) 1);
        f6293c = enumC0642g2;
        EnumC0642g enumC0642g3 = new EnumC0642g("DSA", 2, (byte) 2);
        EnumC0642g enumC0642g4 = new EnumC0642g("ECDSA", 3, (byte) 3);
        f6294d = enumC0642g4;
        EnumC0642g[] enumC0642gArr = {enumC0642g, enumC0642g2, enumC0642g3, enumC0642g4, new EnumC0642g("ED25519", 4, (byte) 7), new EnumC0642g("ED448", 5, (byte) 8)};
        e = enumC0642gArr;
        f6295f = H0.a.z(enumC0642gArr);
        f6292b = new C0592H();
    }

    public EnumC0642g(String str, int i4, byte b5) {
        this.f6296a = b5;
    }

    public static EnumC0642g valueOf(String str) {
        return (EnumC0642g) Enum.valueOf(EnumC0642g.class, str);
    }

    public static EnumC0642g[] values() {
        return (EnumC0642g[]) e.clone();
    }
}
