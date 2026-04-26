package b2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: b2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0245a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0245a[] f3275a;

    static {
        EnumC0245a[] enumC0245aArr = {new EnumC0245a("SEQUENCE", 0), new EnumC0245a("RAW", 1)};
        f3275a = enumC0245aArr;
        H0.a.z(enumC0245aArr);
    }

    public static EnumC0245a valueOf(String str) {
        return (EnumC0245a) Enum.valueOf(EnumC0245a.class, str);
    }

    public static EnumC0245a[] values() {
        return (EnumC0245a[]) f3275a.clone();
    }
}
