package J1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final d f789a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final d f790b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final d f791c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ d[] f792d;

    static {
        d dVar = new d("PREVIEW", 0);
        f789a = dVar;
        d dVar2 = new d("OUTPUT", 1);
        f790b = dVar2;
        d dVar3 = new d("ALL", 2);
        f791c = dVar3;
        d[] dVarArr = {dVar, dVar2, dVar3};
        f792d = dVarArr;
        H0.a.z(dVarArr);
    }

    public static d valueOf(String str) {
        return (d) Enum.valueOf(d.class, str);
    }

    public static d[] values() {
        return (d[]) f792d.clone();
    }
}
