package n2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: n2.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0559b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0559b f5865b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0559b f5866c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0559b f5867d;
    public static final EnumC0559b e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ EnumC0559b[] f5868f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f5869a;

    static {
        EnumC0559b enumC0559b = new EnumC0559b("AAC", 0, (byte) 15);
        f5865b = enumC0559b;
        EnumC0559b enumC0559b2 = new EnumC0559b("AVC", 1, (byte) 27);
        f5866c = enumC0559b2;
        EnumC0559b enumC0559b3 = new EnumC0559b("HEVC", 2, (byte) 36);
        f5867d = enumC0559b3;
        EnumC0559b enumC0559b4 = new EnumC0559b("OPUS", 3, (byte) 6);
        e = enumC0559b4;
        EnumC0559b[] enumC0559bArr = {enumC0559b, enumC0559b2, enumC0559b3, enumC0559b4};
        f5868f = enumC0559bArr;
        H0.a.z(enumC0559bArr);
    }

    public EnumC0559b(String str, int i4, byte b5) {
        this.f5869a = b5;
    }

    public static EnumC0559b valueOf(String str) {
        return (EnumC0559b) Enum.valueOf(EnumC0559b.class, str);
    }

    public static EnumC0559b[] values() {
        return (EnumC0559b[]) f5868f.clone();
    }
}
