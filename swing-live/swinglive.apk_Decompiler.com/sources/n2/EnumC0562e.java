package n2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: n2.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0562e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final EnumC0562e f5875a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final EnumC0562e f5876b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final EnumC0562e f5877c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ EnumC0562e[] f5878d;

    static {
        EnumC0562e enumC0562e = new EnumC0562e("VIDEO", 0);
        f5875a = enumC0562e;
        EnumC0562e enumC0562e2 = new EnumC0562e("AUDIO", 1);
        f5876b = enumC0562e2;
        EnumC0562e enumC0562e3 = new EnumC0562e("PSI", 2);
        f5877c = enumC0562e3;
        EnumC0562e[] enumC0562eArr = {enumC0562e, enumC0562e2, enumC0562e3};
        f5878d = enumC0562eArr;
        H0.a.z(enumC0562eArr);
    }

    public static EnumC0562e valueOf(String str) {
        return (EnumC0562e) Enum.valueOf(EnumC0562e.class, str);
    }

    public static EnumC0562e[] values() {
        return (EnumC0562e[]) f5878d.clone();
    }
}
