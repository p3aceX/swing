package w2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f6713b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ b[] f6714c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6715a;

    static {
        b bVar = new b("FIRST", 0, 2);
        b bVar2 = new b("MIDDLE", 1, 0);
        b bVar3 = new b("LAST", 2, 1);
        b bVar4 = new b("SINGLE", 3, 3);
        f6713b = bVar4;
        b[] bVarArr = {bVar, bVar2, bVar3, bVar4};
        f6714c = bVarArr;
        H0.a.z(bVarArr);
    }

    public b(String str, int i4, int i5) {
        this.f6715a = i5;
    }

    public static b valueOf(String str) {
        return (b) Enum.valueOf(b.class, str);
    }

    public static b[] values() {
        return (b[]) f6714c.clone();
    }
}
