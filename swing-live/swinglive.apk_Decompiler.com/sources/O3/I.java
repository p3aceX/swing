package o3;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: loaded from: classes.dex */
public final class I {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0592H f6003b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final I[] f6004c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final I f6005d;
    public static final I e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final I f6006f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final I f6007m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final I f6008n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final I f6009o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final /* synthetic */ I[] f6010p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final /* synthetic */ B3.b f6011q;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6012a;

    /* JADX WARN: Multi-variable type inference failed */
    static {
        Object next;
        I i4 = new I("HelloRequest", 0, 0);
        f6005d = i4;
        I i5 = new I("ClientHello", 1, 1);
        e = i5;
        I i6 = new I("ServerHello", 2, 2);
        f6006f = i6;
        I i7 = new I("Certificate", 3, 11);
        f6007m = i7;
        I i8 = new I("ServerKeyExchange", 4, 12);
        I i9 = new I("CertificateRequest", 5, 13);
        I i10 = new I("ServerDone", 6, 14);
        I i11 = new I("CertificateVerify", 7, 15);
        I i12 = new I("ClientKeyExchange", 8, 16);
        f6008n = i12;
        I i13 = new I("Finished", 9, 20);
        f6009o = i13;
        I[] iArr = {i4, i5, i6, i7, i8, i9, i10, i11, i12, i13};
        f6010p = iArr;
        f6011q = H0.a.z(iArr);
        f6003b = new C0592H();
        I[] iArr2 = new I[256];
        for (int i14 = 0; i14 < 256; i14++) {
            B3.b bVar = f6011q;
            bVar.getClass();
            J3.a aVar = new J3.a(bVar);
            while (true) {
                if (aVar.hasNext()) {
                    next = aVar.next();
                    if (((I) next).f6012a == i14) {
                        break;
                    }
                } else {
                    next = null;
                    break;
                }
            }
            iArr2[i14] = next;
        }
        f6004c = iArr2;
    }

    public I(String str, int i4, int i5) {
        this.f6012a = i5;
    }

    public static I valueOf(String str) {
        return (I) Enum.valueOf(I.class, str);
    }

    public static I[] values() {
        return (I[]) f6010p.clone();
    }
}
