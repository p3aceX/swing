package C1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final c f126a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c f127b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ c[] f128c;

    static {
        c cVar = new c("UNICAST", 0);
        f126a = cVar;
        c cVar2 = new c("MULTICAST", 1);
        c cVar3 = new c("BROADCAST", 2);
        f127b = cVar3;
        c[] cVarArr = {cVar, cVar2, cVar3};
        f128c = cVarArr;
        H0.a.z(cVarArr);
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f128c.clone();
    }
}
