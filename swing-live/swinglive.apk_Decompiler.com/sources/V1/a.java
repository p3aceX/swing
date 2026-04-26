package V1;

import A3.j;
import I3.p;
import Q3.D;
import w3.i;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class a extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2177a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ b f2178b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ e f2179c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(b bVar, e eVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f2178b = bVar;
        this.f2179c = eVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new a(this.f2178b, this.f2179c, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((a) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:11:0x001e  */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0035  */
    /* JADX WARN: Removed duplicated region for block: B:17:0x003b  */
    /* JADX WARN: Removed duplicated region for block: B:18:0x0041  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:12:0x002c -> B:14:0x002f). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r8) {
        /*
            r7 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r7.f2177a
            r2 = 1
            if (r1 == 0) goto L15
            if (r1 != r2) goto Ld
            e1.AbstractC0367g.M(r8)
            goto L2f
        Ld:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r0)
            throw r8
        L15:
            e1.AbstractC0367g.M(r8)
        L18:
            V1.b r8 = r7.f2178b
            boolean r8 = r8.f2183d
            if (r8 == 0) goto L41
            r8 = 1000(0x3e8, float:1.401E-42)
            long r3 = (long) r8
            V1.b r8 = r7.f2178b
            long r5 = r8.f2182c
            long r3 = r3 / r5
            r7.f2177a = r2
            java.lang.Object r8 = Q3.F.h(r3, r7)
            if (r8 != r0) goto L2f
            return r0
        L2f:
            V1.b r8 = r7.f2178b
            boolean r8 = r8.e
            if (r8 == 0) goto L3b
            V1.b r8 = r7.f2178b
            r1 = 0
            r8.e = r1
            goto L18
        L3b:
            V1.e r8 = r7.f2179c
            r8.a()
            goto L18
        L41:
            w3.i r8 = w3.i.f6729a
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: V1.a.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
