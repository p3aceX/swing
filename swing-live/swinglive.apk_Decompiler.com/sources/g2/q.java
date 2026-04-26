package g2;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class q {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final q f4402b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ q[] f4403c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ B3.b f4404d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte f4405a;

    static {
        q qVar = new q("HARD", 0, (byte) 0);
        q qVar2 = new q("SOFT", 1, (byte) 1);
        q qVar3 = new q("DYNAMIC", 2, (byte) 2);
        f4402b = qVar3;
        q[] qVarArr = {qVar, qVar2, qVar3};
        f4403c = qVarArr;
        f4404d = H0.a.z(qVarArr);
    }

    public q(String str, int i4, byte b5) {
        this.f4405a = b5;
    }

    public static q valueOf(String str) {
        return (q) Enum.valueOf(q.class, str);
    }

    public static q[] values() {
        return (q[]) f4403c.clone();
    }
}
