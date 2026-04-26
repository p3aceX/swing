package S3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final c f1813a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c f1814b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final c f1815c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ c[] f1816d;

    static {
        c cVar = new c("SUSPEND", 0);
        f1813a = cVar;
        c cVar2 = new c("DROP_OLDEST", 1);
        f1814b = cVar2;
        c cVar3 = new c("DROP_LATEST", 2);
        f1815c = cVar3;
        c[] cVarArr = {cVar, cVar2, cVar3};
        f1816d = cVarArr;
        H0.a.z(cVarArr);
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f1816d.clone();
    }
}
