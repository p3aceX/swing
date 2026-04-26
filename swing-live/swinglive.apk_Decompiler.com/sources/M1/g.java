package M1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final g f1084a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final g f1085b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ g[] f1086c;

    static {
        g gVar = new g("BACK", 0);
        f1084a = gVar;
        g gVar2 = new g("FRONT", 1);
        f1085b = gVar2;
        f1086c = new g[]{gVar, gVar2};
    }

    public static g valueOf(String str) {
        return (g) Enum.valueOf(g.class, str);
    }

    public static g[] values() {
        return (g[]) f1086c.clone();
    }
}
