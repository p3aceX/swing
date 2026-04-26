package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class M {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final L f6020b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final M[] f6021c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final M f6022d;
    public static final M e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final M f6023f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final M f6024m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ M[] f6025n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6026o;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6027a;

    /* JADX WARN: Multi-variable type inference failed */
    static {
        Object next;
        M m4 = new M("ChangeCipherSpec", 0, 20);
        f6022d = m4;
        M m5 = new M("Alert", 1, 21);
        e = m5;
        M m6 = new M("Handshake", 2, 22);
        f6023f = m6;
        M m7 = new M("ApplicationData", 3, 23);
        f6024m = m7;
        M[] mArr = {m4, m5, m6, m7};
        f6025n = mArr;
        f6026o = H0.a.z(mArr);
        f6020b = new L();
        M[] mArr2 = new M[256];
        for (int i4 = 0; i4 < 256; i4++) {
            B3.b bVar = f6026o;
            bVar.getClass();
            J3.a aVar = new J3.a(bVar);
            while (true) {
                if (aVar.hasNext()) {
                    next = aVar.next();
                    if (((M) next).f6027a == i4) {
                        break;
                    }
                } else {
                    next = null;
                    break;
                }
            }
            mArr2[i4] = next;
        }
        f6021c = mArr2;
    }

    public M(String str, int i4, int i5) {
        this.f6027a = i5;
    }

    public static M valueOf(String str) {
        return (M) Enum.valueOf(M.class, str);
    }

    public static M[] values() {
        return (M[]) f6025n.clone();
    }
}
