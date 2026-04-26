package c2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: renamed from: c2.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class EnumC0251a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ EnumC0251a[] f3296a;

    static {
        EnumC0251a[] enumC0251aArr = {new EnumC0251a("KEYFRAME", 0), new EnumC0251a("INTER_FRAME", 1)};
        f3296a = enumC0251aArr;
        H0.a.z(enumC0251aArr);
    }

    public static EnumC0251a valueOf(String str) {
        return (EnumC0251a) Enum.valueOf(EnumC0251a.class, str);
    }

    public static EnumC0251a[] values() {
        return (EnumC0251a[]) f3296a.clone();
    }
}
