package f2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: f2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0401a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0401a[] f4285a;

    static {
        EnumC0401a[] enumC0401aArr = {new EnumC0401a("PROTOCOL_CONTROL", 0), new EnumC0401a("OVER_CONNECTION", 1), new EnumC0401a("OVER_CONNECTION2", 2), new EnumC0401a("OVER_STREAM", 3), new EnumC0401a("VIDEO", 4), new EnumC0401a("AUDIO", 5)};
        f4285a = enumC0401aArr;
        H0.a.z(enumC0401aArr);
    }

    public static EnumC0401a valueOf(String str) {
        return (EnumC0401a) Enum.valueOf(EnumC0401a.class, str);
    }

    public static EnumC0401a[] values() {
        return (EnumC0401a[]) f4285a.clone();
    }
}
