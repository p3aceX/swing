package v2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: v2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0694a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0694a[] f6666a;

    static {
        EnumC0694a[] enumC0694aArr = {new EnumC0694a("TSBPDSND", 0), new EnumC0694a("TSBPDRCV", 1), new EnumC0694a("CRYPT", 2), new EnumC0694a("TLPKTDROP", 3), new EnumC0694a("PERIODICNAK", 4), new EnumC0694a("REXMITFLG", 5), new EnumC0694a("STREAM", 6), new EnumC0694a("PACKET_FILTER", 7)};
        f6666a = enumC0694aArr;
        H0.a.z(enumC0694aArr);
    }

    public static EnumC0694a valueOf(String str) {
        return (EnumC0694a) Enum.valueOf(EnumC0694a.class, str);
    }

    public static EnumC0694a[] values() {
        return (EnumC0694a[]) f6666a.clone();
    }
}
