package G3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ b[] f497a;

    static {
        b[] bVarArr = {new b("PRESENT", 0), new b("ABSENT", 1), new b("PRESENT_OPTIONAL", 2), new b("ABSENT_OPTIONAL", 3)};
        f497a = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f497a.clone();
    }
}
