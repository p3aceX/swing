package O1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final a f1443a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final a f1444b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ a[] f1445c;

    static {
        a aVar = new a("Adjust", 0);
        f1443a = aVar;
        a aVar2 = new a("Fill", 1);
        a aVar3 = new a("NONE", 2);
        f1444b = aVar3;
        a[] aVarArr = {aVar, aVar2, aVar3};
        f1445c = aVarArr;
        H0.a.z(aVarArr);
    }

    public static a valueOf(String str) {
        return (a) Enum.valueOf(a.class, str);
    }

    public static a[] values() {
        return (a[]) f1445c.clone();
    }
}
