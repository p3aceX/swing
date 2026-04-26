package A1;

import A3.j;
import I3.p;
import Q3.D;
import w3.i;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class a extends j implements p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f67a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ d f68b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public a(d dVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f68b = dVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new a(this.f68b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((a) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    /* JADX WARN: Removed duplicated region for block: B:11:0x001c  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:19:0x004d -> B:11:0x001c). Please report as a decompilation issue!!! */
    @Override // A3.a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r9) {
        /*
            r8 = this;
            z3.a r0 = z3.EnumC0789a.f6999a
            int r1 = r8.f67a
            r2 = 2
            r3 = 1
            if (r1 == 0) goto L19
            if (r1 == r3) goto L15
            if (r1 != r2) goto Ld
            goto L19
        Ld:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r0)
            throw r9
        L15:
            e1.AbstractC0367g.M(r9)
            goto L3f
        L19:
            e1.AbstractC0367g.M(r9)
        L1c:
            A1.d r9 = r8.f68b
            V3.d r9 = r9.f82h
            boolean r9 = Q3.F.q(r9)
            if (r9 == 0) goto L50
            A1.d r9 = r8.f68b
            boolean r9 = r9.f78c
            if (r9 == 0) goto L50
            A1.d r9 = r8.f68b
            y1.d r1 = r9.e
            long r4 = r9.f83i
            r9 = 8
            long r6 = (long) r9
            long r4 = r4 * r6
            r8.f67a = r3
            java.lang.Object r9 = r1.a(r4, r8)
            if (r9 != r0) goto L3f
            goto L4f
        L3f:
            A1.d r9 = r8.f68b
            r4 = 0
            r9.f83i = r4
            r8.f67a = r2
            r4 = 1000(0x3e8, double:4.94E-321)
            java.lang.Object r9 = Q3.F.h(r4, r8)
            if (r9 != r0) goto L1c
        L4f:
            return r0
        L50:
            w3.i r9 = w3.i.f6729a
            return r9
        */
        throw new UnsupportedOperationException("Method not decompiled: A1.a.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
