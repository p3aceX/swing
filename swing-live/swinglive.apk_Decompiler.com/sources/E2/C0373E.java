package e2;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: e2.E, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0373E extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public L f4019a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4020b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f4021c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f4022d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f4023f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ String f4024m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final /* synthetic */ L f4025n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0373E(String str, L l2, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4024m = str;
        this.f4025n = l2;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        C0373E c0373e = new C0373E(this.f4024m, this.f4025n, interfaceC0762c);
        c0373e.f4023f = obj;
        return c0373e;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((C0373E) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:40:0x00de  */
    /* JADX WARN: Removed duplicated region for block: B:41:0x00e1  */
    /* JADX WARN: Removed duplicated region for block: B:47:0x00f2  */
    /* JADX WARN: Removed duplicated region for block: B:48:0x00f7  */
    /* JADX WARN: Removed duplicated region for block: B:51:0x0137  */
    /* JADX WARN: Removed duplicated region for block: B:52:0x0144  */
    /* JADX WARN: Removed duplicated region for block: B:55:0x014f  */
    /* JADX WARN: Removed duplicated region for block: B:56:0x0158  */
    /* JADX WARN: Removed duplicated region for block: B:59:0x018f  */
    /* JADX WARN: Removed duplicated region for block: B:62:0x01ab  */
    /* JADX WARN: Removed duplicated region for block: B:70:0x01cd  */
    /* JADX WARN: Removed duplicated region for block: B:75:0x01e6 A[ADDED_TO_REGION] */
    /* JADX WARN: Removed duplicated region for block: B:80:0x0203  */
    /* JADX WARN: Removed duplicated region for block: B:81:0x0205 A[Catch: all -> 0x022a, PHI: r0 r3 r6 r9
      0x0205: PHI (r0v18 int) = (r0v10 int), (r0v22 int) binds: [B:79:0x0201, B:25:0x0068] A[DONT_GENERATE, DONT_INLINE]
      0x0205: PHI (r3v21 java.lang.Object) = (r3v15 java.lang.Object), (r3v29 java.lang.Object) binds: [B:79:0x0201, B:25:0x0068] A[DONT_GENERATE, DONT_INLINE]
      0x0205: PHI (r6v7 e2.L) = (r6v3 e2.L), (r6v8 e2.L) binds: [B:79:0x0201, B:25:0x0068] A[DONT_GENERATE, DONT_INLINE]
      0x0205: PHI (r9v15 int) = (r9v13 int), (r9v16 int) binds: [B:79:0x0201, B:25:0x0068] A[DONT_GENERATE, DONT_INLINE], TryCatch #0 {all -> 0x022a, blocks: (B:81:0x0205, B:83:0x020d, B:89:0x022c, B:91:0x0230, B:110:0x029a, B:111:0x02a1, B:78:0x01f2), top: B:122:0x01f2 }] */
    /* JADX WARN: Removed duplicated region for block: B:83:0x020d A[Catch: all -> 0x022a, TryCatch #0 {all -> 0x022a, blocks: (B:81:0x0205, B:83:0x020d, B:89:0x022c, B:91:0x0230, B:110:0x029a, B:111:0x02a1, B:78:0x01f2), top: B:122:0x01f2 }] */
    /* JADX WARN: Removed duplicated region for block: B:89:0x022c A[Catch: all -> 0x022a, TryCatch #0 {all -> 0x022a, blocks: (B:81:0x0205, B:83:0x020d, B:89:0x022c, B:91:0x0230, B:110:0x029a, B:111:0x02a1, B:78:0x01f2), top: B:122:0x01f2 }] */
    /* JADX WARN: Removed duplicated region for block: B:97:0x025f  */
    /* JADX WARN: Removed duplicated region for block: B:98:0x0261  */
    /*  JADX ERROR: JadxRuntimeException in pass: RegionMakerVisitor
        jadx.core.utils.exceptions.JadxRuntimeException: Not found exit edge by exit block: B:100:0x0268
        	at jadx.core.dex.visitors.regions.maker.LoopRegionMaker.checkLoopExits(LoopRegionMaker.java:226)
        	at jadx.core.dex.visitors.regions.maker.LoopRegionMaker.makeLoopRegion(LoopRegionMaker.java:196)
        	at jadx.core.dex.visitors.regions.maker.LoopRegionMaker.process(LoopRegionMaker.java:63)
        	at jadx.core.dex.visitors.regions.maker.RegionMaker.traverse(RegionMaker.java:89)
        	at jadx.core.dex.visitors.regions.maker.RegionMaker.makeRegion(RegionMaker.java:66)
        	at jadx.core.dex.visitors.regions.maker.SwitchRegionMaker.addCases(SwitchRegionMaker.java:123)
        	at jadx.core.dex.visitors.regions.maker.SwitchRegionMaker.process(SwitchRegionMaker.java:71)
        	at jadx.core.dex.visitors.regions.maker.RegionMaker.traverse(RegionMaker.java:112)
        	at jadx.core.dex.visitors.regions.maker.RegionMaker.makeRegion(RegionMaker.java:66)
        	at jadx.core.dex.visitors.regions.maker.RegionMaker.makeMthRegion(RegionMaker.java:48)
        	at jadx.core.dex.visitors.regions.RegionMakerVisitor.visit(RegionMakerVisitor.java:25)
        */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r18) {
        /*
            Method dump skipped, instruction units count: 776
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e2.C0373E.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
