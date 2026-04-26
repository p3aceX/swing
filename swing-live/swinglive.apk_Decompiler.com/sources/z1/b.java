package Z1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final b f2597a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f2598b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ b[] f2599c;

    static {
        b bVar = new b("AUDIO", 0);
        f2597a = bVar;
        b bVar2 = new b("VIDEO", 1);
        f2598b = bVar2;
        b[] bVarArr = {bVar, bVar2};
        f2599c = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f2599c.clone();
    }
}
