package X3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final b f2422a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f2423b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final b f2424c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final b f2425d;
    public static final b e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ b[] f2426f;

    static {
        b bVar = new b("CPU_ACQUIRED", 0);
        f2422a = bVar;
        b bVar2 = new b("BLOCKING", 1);
        f2423b = bVar2;
        b bVar3 = new b("PARKING", 2);
        f2424c = bVar3;
        b bVar4 = new b("DORMANT", 3);
        f2425d = bVar4;
        b bVar5 = new b("TERMINATED", 4);
        e = bVar5;
        b[] bVarArr = {bVar, bVar2, bVar3, bVar4, bVar5};
        f2426f = bVarArr;
        H0.a.z(bVarArr);
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f2426f.clone();
    }
}
