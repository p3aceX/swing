package o3;

import I.C0053n;
import Q3.C0136j0;
import Q3.InterfaceC0132h0;
import Q3.InterfaceC0147t;
import io.ktor.utils.io.C0449m;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.crypto.spec.SecretKeySpec;
import p3.C0618a;
import p3.C0622e;
import p3.InterfaceC0623f;
import q3.AbstractC0643h;
import q3.C0637b;
import x3.AbstractC0726f;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: o3.D, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0588D implements Q3.D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0053n f5986a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final X3.d f5987b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final InterfaceC0147t f5988c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Z3.a f5989d;
    public final byte[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final w3.f f5990f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final w3.f f5991m;
    private volatile SecretKeySpec masterSecret;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final S3.t f5992n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public boolean f5993o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final S3.a f5994p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final S3.t f5995q;
    private volatile O serverHello;

    public C0588D(C0449m c0449m, C0449m c0449m2, C0053n c0053n, X3.d dVar) {
        final int i4 = 1;
        final int i5 = 0;
        C0136j0 c0136j0 = new C0136j0(null);
        J3.i.e(c0449m, "rawInput");
        J3.i.e(c0449m2, "rawOutput");
        J3.i.e(c0053n, "config");
        J3.i.e(dVar, "coroutineContext");
        this.f5986a = c0053n;
        this.f5987b = dVar;
        this.f5988c = c0136j0;
        this.f5989d = new Z3.a();
        byte[] bArr = new byte[32];
        ((SecureRandom) c0053n.f706b).nextBytes(bArr);
        long jCurrentTimeMillis = System.currentTimeMillis() / 1000;
        bArr[0] = (byte) (jCurrentTimeMillis >> 24);
        bArr[1] = (byte) (jCurrentTimeMillis >> 16);
        bArr[2] = (byte) (jCurrentTimeMillis >> 8);
        bArr[3] = (byte) jCurrentTimeMillis;
        this.e = bArr;
        this.f5990f = new w3.f(new I3.a(this) { // from class: o3.q

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ C0588D f6133b;

            {
                this.f6133b = this;
            }

            @Override // I3.a
            public final Object a() {
                switch (i5) {
                    case 0:
                        return C0588D.b(this.f6133b);
                    default:
                        return C0588D.a(this.f6133b);
                }
            }
        });
        this.f5991m = new w3.f(new I3.a(this) { // from class: o3.q

            /* JADX INFO: renamed from: b, reason: collision with root package name */
            public final /* synthetic */ C0588D f6133b;

            {
                this.f6133b = this;
            }

            @Override // I3.a
            public final Object a() {
                switch (i4) {
                    case 0:
                        return C0588D.b(this.f6133b);
                    default:
                        return C0588D.a(this.f6133b);
                }
            }
        });
        this.f5992n = S3.m.c(this, new Q3.C("cio-tls-parser"), new C0612u(c0449m, this, null));
        Q3.C c5 = new Q3.C("cio-tls-encoder");
        I3.p c0614w = new C0614w(c0449m2, this, null);
        Q3.E e = Q3.E.f1571a;
        InterfaceC0767h interfaceC0767hT = Q3.F.t(this, c5);
        S3.e eVarA = S3.m.a(0, null, 6);
        Q3.E e4 = Q3.E.f1571a;
        S3.a aVar = new S3.a(interfaceC0767hT, eVarA, false, true);
        aVar.L((InterfaceC0132h0) interfaceC0767hT.i(Q3.B.f1565b));
        aVar.e0(e, aVar, c0614w);
        aVar.f0(new M1.a(3, this, c0449m2));
        this.f5994p = aVar;
        this.f5995q = S3.m.c(this, new Q3.C("cio-tls-handshake"), new C0611t(this, null));
    }

    public static InterfaceC0623f a(C0588D c0588d) {
        O o4 = c0588d.serverHello;
        if (o4 == null) {
            J3.i.g("serverHello");
            throw null;
        }
        C0594b c0594b = o4.f6031c;
        byte[] bArr = (byte[]) c0588d.f5990f.a();
        J3.i.e(c0594b, "suite");
        J3.i.e(bArr, "keyMaterial");
        int iOrdinal = c0594b.f6078n.ordinal();
        if (iOrdinal == 0) {
            return new C0622e(c0594b, bArr);
        }
        if (iOrdinal == 1) {
            return new C0618a(c0594b, bArr);
        }
        throw new A0.b();
    }

    public static byte[] b(C0588D c0588d) {
        O o4 = c0588d.serverHello;
        if (o4 == null) {
            J3.i.g("serverHello");
            throw null;
        }
        C0594b c0594b = o4.f6031c;
        SecretKeySpec secretKeySpec = c0588d.masterSecret;
        if (secretKeySpec == null) {
            J3.i.g("masterSecret");
            throw null;
        }
        O o5 = c0588d.serverHello;
        if (o5 == null) {
            J3.i.g("serverHello");
            throw null;
        }
        byte[] bArrJ0 = AbstractC0726f.j0(o5.f6029a, c0588d.e);
        int i4 = c0594b.f6079o;
        int i5 = c0594b.f6080p;
        int i6 = c0594b.f6071g * 2;
        return e1.k.a(secretKeySpec, AbstractC0598f.f6089b, bArrJ0, i6 + (i4 * 2) + (i5 * 2));
    }

    /* JADX WARN: Code restructure failed: missing block: B:149:0x03ed, code lost:
    
        r5 = true;
     */
    /* JADX WARN: Code restructure failed: missing block: B:31:0x00a9, code lost:
    
        if (d(r13, (java.security.cert.Certificate) r1, r11, r8, r6) == r7) goto L32;
     */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Path cross not found for [B:141:0x03cb, B:140:0x03c9], limit reached: 183 */
    /* JADX WARN: Removed duplicated region for block: B:114:0x0301  */
    /* JADX WARN: Removed duplicated region for block: B:22:0x0071 A[PHI: r1 r2 r3 r4 r5 r6 r7 r8 r9 r11 r12 r13
      0x0071: PHI (r1v8 java.lang.Object) = (r1v7 java.lang.Object), (r1v1 java.lang.Object) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r2v2 int A[IMMUTABLE_TYPE]) = (r2v1 int), (r2v0 int) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r3v2 int) = (r3v1 int), (r3v0 int) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r4v2 int) = (r4v1 int), (r4v0 int) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r5v2 int) = (r5v1 int), (r5v0 int) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r6v4 o3.r) = (r6v3 o3.r), (r6v2 o3.r) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r7v3 z3.a) = (r7v1 z3.a), (r7v0 z3.a) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r8v4 o3.e) = (r8v3 o3.e), (r8v18 o3.e) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r9v2 ??) = (r9v30 ??), (r9v29 ?? I:??[int, float, boolean, short, byte, char, OBJECT, ARRAY]) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r11v2 X.N) = (r11v1 X.N), (r11v5 X.N) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r12v2 J3.r) = (r12v1 J3.r), (r12v3 J3.r) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]
      0x0071: PHI (r13v2 o3.l) = (r13v1 o3.l), (r13v27 o3.l) binds: [B:20:0x006e, B:15:0x003c] A[DONT_GENERATE, DONT_INLINE]] */
    /* JADX WARN: Removed duplicated region for block: B:24:0x0084  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x001b  */
    /* JADX WARN: Type inference failed for: r23v0, types: [o3.D] */
    /* JADX WARN: Type inference failed for: r24v2 */
    /* JADX WARN: Type inference failed for: r24v3, types: [java.lang.Throwable] */
    /* JADX WARN: Type inference failed for: r24v4 */
    /* JADX WARN: Type inference failed for: r24v5 */
    /* JADX WARN: Type inference failed for: r3v13 */
    /* JADX WARN: Type inference failed for: r3v14 */
    /* JADX WARN: Type inference failed for: r3v18, types: [java.lang.Object] */
    /* JADX WARN: Type inference failed for: r5v19 */
    /* JADX WARN: Type inference failed for: r5v20, types: [java.lang.Enum] */
    /* JADX WARN: Type inference failed for: r5v50 */
    /* JADX WARN: Type inference failed for: r8v16, types: [java.lang.Object] */
    /* JADX WARN: Type inference failed for: r8v8 */
    /* JADX WARN: Type inference failed for: r8v9 */
    /* JADX WARN: Type inference failed for: r9v0 */
    /* JADX WARN: Type inference failed for: r9v1 */
    /* JADX WARN: Type inference failed for: r9v18 */
    /* JADX WARN: Type inference failed for: r9v2, types: [J3.r, X.N, o3.e, o3.l] */
    /* JADX WARN: Type inference failed for: r9v22 */
    /* JADX WARN: Type inference failed for: r9v24 */
    /* JADX WARN: Type inference failed for: r9v27 */
    /* JADX WARN: Type inference failed for: r9v29 */
    /* JADX WARN: Type inference failed for: r9v30 */
    /* JADX WARN: Type inference failed for: r9v31 */
    /* JADX WARN: Type inference failed for: r9v32 */
    /* JADX WARN: Type inference failed for: r9v5 */
    /* JADX WARN: Type inference failed for: r9v8 */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:20:0x006e -> B:22:0x0071). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object c(A3.c r24) throws java.security.spec.InvalidKeySpecException, java.security.NoSuchAlgorithmException, java.security.SignatureException, java.security.InvalidKeyException, java.security.cert.CertificateException, java.io.EOFException, o3.C0590F, java.security.InvalidAlgorithmParameterException {
        /*
            Method dump skipped, instruction units count: 1071
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.c(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:105:0x024f  */
    /* JADX WARN: Removed duplicated region for block: B:37:0x00ab  */
    /* JADX WARN: Removed duplicated region for block: B:74:0x018f  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x001b  */
    /* JADX WARN: Removed duplicated region for block: B:80:0x01d4  */
    /* JADX WARN: Removed duplicated region for block: B:82:0x01d8  */
    /* JADX WARN: Removed duplicated region for block: B:93:0x021d  */
    /* JADX WARN: Removed duplicated region for block: B:97:0x0227  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object d(o3.EnumC0604l r18, java.security.cert.Certificate r19, X.N r20, o3.C0597e r21, A3.c r22) throws java.lang.Exception {
        /*
            Method dump skipped, instruction units count: 595
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.d(o3.l, java.security.cert.Certificate, X.N, o3.e, A3.c):java.lang.Object");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:43:0x009d  */
    /* JADX WARN: Removed duplicated region for block: B:44:0x009e  */
    /* JADX WARN: Removed duplicated region for block: B:47:0x00ab A[Catch: all -> 0x00d3, TryCatch #0 {all -> 0x00d3, blocks: (B:50:0x00bd, B:45:0x00a2, B:47:0x00ab, B:60:0x00d5, B:61:0x00da, B:41:0x008f, B:35:0x0075), top: B:70:0x0075 }] */
    /* JADX WARN: Removed duplicated region for block: B:53:0x00ca  */
    /* JADX WARN: Removed duplicated region for block: B:55:0x00cd  */
    /* JADX WARN: Removed duplicated region for block: B:60:0x00d5 A[Catch: all -> 0x00d3, TRY_ENTER, TryCatch #0 {all -> 0x00d3, blocks: (B:50:0x00bd, B:45:0x00a2, B:47:0x00ab, B:60:0x00d5, B:61:0x00da, B:41:0x008f, B:35:0x0075), top: B:70:0x0075 }] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r0v10 */
    /* JADX WARN: Type inference failed for: r0v11 */
    /* JADX WARN: Type inference failed for: r0v14 */
    /* JADX WARN: Type inference failed for: r0v3 */
    /* JADX WARN: Type inference failed for: r0v4 */
    /* JADX WARN: Type inference failed for: r0v6, types: [o3.d] */
    /* JADX WARN: Type inference failed for: r0v7, types: [o3.d] */
    /* JADX WARN: Type inference failed for: r0v9, types: [o3.d] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object e(A3.c r12) throws java.lang.IllegalAccessException, java.lang.reflect.InvocationTargetException {
        /*
            Method dump skipped, instruction units count: 232
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.e(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object f(A3.c r15) throws java.security.NoSuchAlgorithmException, java.security.InvalidKeyException, java.io.EOFException, o3.C0590F {
        /*
            Method dump skipped, instruction units count: 342
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.f(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object g(A3.c r14) throws java.io.EOFException, o3.C0590F {
        /*
            Method dump skipped, instruction units count: 336
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.g(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object h(A3.c r8) throws java.lang.Throwable {
        /*
            r7 = this;
            boolean r0 = r8 instanceof o3.C0585A
            if (r0 == 0) goto L13
            r0 = r8
            o3.A r0 = (o3.C0585A) r0
            int r1 = r0.f5978d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5978d = r1
            goto L18
        L13:
            o3.A r0 = new o3.A
            r0.<init>(r7, r8)
        L18:
            java.lang.Object r8 = r0.f5976b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5978d
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            Z3.a r0 = r0.f5975a
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L29
            goto L52
        L29:
            r8 = move-exception
            goto L59
        L2b:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L33:
            e1.AbstractC0367g.M(r8)
            Z3.a r8 = new Z3.a
            r8.<init>()
            r8.n(r3)
            S3.a r2 = r7.f5994p     // Catch: java.lang.Throwable -> L55
            o3.K r4 = new o3.K     // Catch: java.lang.Throwable -> L55
            o3.M r5 = o3.M.f6022d     // Catch: java.lang.Throwable -> L55
            r4.<init>(r5, r8)     // Catch: java.lang.Throwable -> L55
            r0.f5975a = r8     // Catch: java.lang.Throwable -> L55
            r0.f5978d = r3     // Catch: java.lang.Throwable -> L55
            java.lang.Object r8 = r2.m(r4, r0)     // Catch: java.lang.Throwable -> L55
            if (r8 != r1) goto L52
            return r1
        L52:
            w3.i r8 = w3.i.f6729a
            return r8
        L55:
            r0 = move-exception
            r6 = r0
            r0 = r8
            r8 = r6
        L59:
            r0.getClass()
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.h(A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final z3.EnumC0789a i(A3.c r7) {
        /*
            r6 = this;
            boolean r0 = r7 instanceof o3.C0586B
            if (r0 == 0) goto L13
            r0 = r7
            o3.B r0 = (o3.C0586B) r0
            int r1 = r0.f5981c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5981c = r1
            goto L18
        L13:
            o3.B r0 = new o3.B
            r0.<init>(r6, r7)
        L18:
            java.lang.Object r7 = r0.f5979a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5981c
            r3 = 1
            r4 = 0
            if (r2 == 0) goto L30
            if (r2 != r3) goto L28
            e1.AbstractC0367g.M(r7)
            return r4
        L28:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r0)
            throw r7
        L30:
            e1.AbstractC0367g.M(r7)
            I.n r7 = r6.f5986a
            java.lang.Object r7 = r7.f707c
            java.util.ArrayList r7 = (java.util.ArrayList) r7
            java.util.Iterator r7 = r7.iterator()
            boolean r2 = r7.hasNext()
            if (r2 != 0) goto L55
            o3.I r7 = o3.I.f6007m
            Q3.y r2 = new Q3.y
            r5 = 2
            r2.<init>(r5)
            r0.f5981c = r3
            java.lang.Object r7 = r6.j(r7, r2, r0)
            if (r7 != r1) goto L54
            return r1
        L54:
            return r4
        L55:
            java.lang.Object r7 = r7.next()
            r7.getClass()
            java.lang.ClassCastException r7 = new java.lang.ClassCastException
            r7.<init>()
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.i(A3.c):z3.a");
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r7v6, types: [java.lang.Object, w3.i] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object j(o3.I r7, I3.l r8, A3.c r9) throws java.lang.Exception {
        /*
            r6 = this;
            boolean r0 = r9 instanceof o3.C0587C
            if (r0 == 0) goto L13
            r0 = r9
            o3.C r0 = (o3.C0587C) r0
            int r1 = r0.f5985d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f5985d = r1
            goto L18
        L13:
            o3.C r0 = new o3.C
            r0.<init>(r6, r9)
        L18:
            java.lang.Object r9 = r0.f5983b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f5985d
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            o3.K r7 = r0.f5982a
            e1.AbstractC0367g.M(r9)     // Catch: java.lang.Throwable -> L29
            goto L67
        L29:
            r8 = move-exception
            goto L6a
        L2b:
            java.lang.IllegalStateException r7 = new java.lang.IllegalStateException
            java.lang.String r8 = "call to 'resume' before 'invoke' with coroutine"
            r7.<init>(r8)
            throw r7
        L33:
            e1.AbstractC0367g.M(r9)
            Z3.a r9 = new Z3.a
            r9.<init>()
            r8.invoke(r9)
            Z3.a r8 = new Z3.a
            r8.<init>()
            long r4 = u3.AbstractC0692a.a(r9)
            int r2 = (int) r4
            e1.k.N(r8, r7, r2)
            u3.AbstractC0692a.d(r8, r9)
            Z3.a r7 = r6.f5989d
            o3.C0596d.b(r7, r8)
            o3.K r7 = new o3.K
            o3.M r9 = o3.M.f6023f
            r7.<init>(r9, r8)
            S3.a r8 = r6.f5994p     // Catch: java.lang.Throwable -> L29
            r0.f5982a = r7     // Catch: java.lang.Throwable -> L29
            r0.f5985d = r3     // Catch: java.lang.Throwable -> L29
            java.lang.Object r7 = r8.m(r7, r0)     // Catch: java.lang.Throwable -> L29
            if (r7 != r1) goto L67
            return r1
        L67:
            w3.i r7 = w3.i.f6729a
            return r7
        L6a:
            Z3.h r7 = r7.f6019c
            r7.close()
            throw r8
        */
        throw new UnsupportedOperationException("Method not decompiled: o3.C0588D.j(o3.I, I3.l, A3.c):java.lang.Object");
    }

    public final void k(O o4) throws C0590F {
        C0594b c0594b = o4.f6031c;
        if (!((ArrayList) this.f5986a.e).contains(c0594b)) {
            throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.h(new StringBuilder("Unsupported cipher suite "), c0594b.f6067b, " in SERVER_HELLO").toString());
        }
        List list = AbstractC0643h.f6297a;
        ArrayList arrayList = new ArrayList();
        for (Object obj : list) {
            C0637b c0637b = (C0637b) obj;
            if (c0637b.f6276a == c0594b.f6076l && c0637b.f6277b == c0594b.f6077m) {
                arrayList.add(obj);
            }
        }
        if (arrayList.isEmpty()) {
            throw new C0590F("No appropriate hash algorithm for suite: " + c0594b, 0);
        }
        ArrayList arrayList2 = o4.f6032d;
        if (arrayList2.isEmpty()) {
            return;
        }
        if (!arrayList.isEmpty()) {
            Iterator it = arrayList.iterator();
            while (it.hasNext()) {
                if (arrayList2.contains((C0637b) it.next())) {
                    return;
                }
            }
        }
        throw new C0590F("No sign algorithms in common. \nServer candidates: " + arrayList2 + " \nClient candidates: " + arrayList, 0);
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.f5987b;
    }
}
