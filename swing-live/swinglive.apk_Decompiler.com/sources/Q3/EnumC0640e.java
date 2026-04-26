package q3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: q3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0640e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0640e f6287b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0640e f6288c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final EnumC0640e f6289d;
    public static final /* synthetic */ EnumC0640e[] e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f6290a;

    static {
        EnumC0640e enumC0640e = new EnumC0640e("UNCOMPRESSED", 0, (byte) 0);
        f6287b = enumC0640e;
        EnumC0640e enumC0640e2 = new EnumC0640e("ANSIX962_COMPRESSED_PRIME", 1, (byte) 1);
        f6288c = enumC0640e2;
        EnumC0640e enumC0640e3 = new EnumC0640e("ANSIX962_COMPRESSED_CHAR2", 2, (byte) 2);
        f6289d = enumC0640e3;
        EnumC0640e[] enumC0640eArr = {enumC0640e, enumC0640e2, enumC0640e3};
        e = enumC0640eArr;
        H0.a.z(enumC0640eArr);
    }

    public EnumC0640e(String str, int i4, byte b5) {
        this.f6290a = b5;
    }

    public static EnumC0640e valueOf(String str) {
        return (EnumC0640e) Enum.valueOf(EnumC0640e.class, str);
    }

    public static EnumC0640e[] values() {
        return (EnumC0640e[]) e.clone();
    }
}
