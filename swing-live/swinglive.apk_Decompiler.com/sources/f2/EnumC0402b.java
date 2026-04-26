package f2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: f2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0402b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0402b f4286b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0402b f4287c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0402b[] f4288d;
    public static final /* synthetic */ B3.b e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f4289a;

    static {
        EnumC0402b enumC0402b = new EnumC0402b("TYPE_0", 0, (byte) 0);
        f4286b = enumC0402b;
        EnumC0402b enumC0402b2 = new EnumC0402b("TYPE_1", 1, (byte) 1);
        EnumC0402b enumC0402b3 = new EnumC0402b("TYPE_2", 2, (byte) 2);
        EnumC0402b enumC0402b4 = new EnumC0402b("TYPE_3", 3, (byte) 3);
        f4287c = enumC0402b4;
        EnumC0402b[] enumC0402bArr = {enumC0402b, enumC0402b2, enumC0402b3, enumC0402b4};
        f4288d = enumC0402bArr;
        e = H0.a.z(enumC0402bArr);
    }

    public EnumC0402b(String str, int i4, byte b5) {
        this.f4289a = b5;
    }

    public static EnumC0402b valueOf(String str) {
        return (EnumC0402b) Enum.valueOf(EnumC0402b.class, str);
    }

    public static EnumC0402b[] values() {
        return (EnumC0402b[]) f4288d.clone();
    }
}
