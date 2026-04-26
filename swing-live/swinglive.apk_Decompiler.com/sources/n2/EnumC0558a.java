package n2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: n2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0558a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0558a f5861b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0558a f5862c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0558a[] f5863d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f5864a;

    static {
        EnumC0558a enumC0558a = new EnumC0558a("PAYLOAD", 0, (byte) 1);
        f5861b = enumC0558a;
        EnumC0558a enumC0558a2 = new EnumC0558a("ADAPTATION", 1, (byte) 2);
        EnumC0558a enumC0558a3 = new EnumC0558a("ADAPTATION_PAYLOAD", 2, (byte) 3);
        f5862c = enumC0558a3;
        EnumC0558a[] enumC0558aArr = {enumC0558a, enumC0558a2, enumC0558a3, new EnumC0558a("RESERVED", 3, (byte) 0)};
        f5863d = enumC0558aArr;
        H0.a.z(enumC0558aArr);
    }

    public EnumC0558a(String str, int i4, byte b5) {
        this.f5864a = b5;
    }

    public static EnumC0558a valueOf(String str) {
        return (EnumC0558a) Enum.valueOf(EnumC0558a.class, str);
    }

    public static EnumC0558a[] values() {
        return (EnumC0558a[]) f5863d.clone();
    }
}
