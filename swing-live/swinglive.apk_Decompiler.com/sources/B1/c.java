package B1;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final c f112a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c f113b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ c[] f114c;

    static {
        c cVar = new c("VIDEO", 0);
        f112a = cVar;
        c cVar2 = new c("AUDIO", 1);
        f113b = cVar2;
        c[] cVarArr = {cVar, cVar2};
        f114c = cVarArr;
        H0.a.z(cVarArr);
    }

    public static c valueOf(String str) {
        return (c) Enum.valueOf(c.class, str);
    }

    public static c[] values() {
        return (c[]) f114c.clone();
    }
}
