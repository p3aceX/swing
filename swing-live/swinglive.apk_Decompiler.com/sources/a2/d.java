package a2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final d f2638b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ d[] f2639c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f2640a;

    static {
        d dVar = new d("SND_8_BIT", 0, 0);
        d dVar2 = new d("SND_16_BIT", 1, 1);
        f2638b = dVar2;
        d[] dVarArr = {dVar, dVar2};
        f2639c = dVarArr;
        H0.a.z(dVarArr);
    }

    public d(String str, int i4, int i5) {
        this.f2640a = i5;
    }

    public static d valueOf(String str) {
        return (d) Enum.valueOf(d.class, str);
    }

    public static d[] values() {
        return (d[]) f2639c.clone();
    }
}
