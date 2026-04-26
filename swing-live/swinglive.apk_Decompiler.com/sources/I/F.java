package I;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class F extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Throwable f551a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f552b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ boolean f553c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ Q f554d;
    public final /* synthetic */ int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public F(Q q4, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f554d = q4;
        this.e = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        F f4 = new F(this.f554d, this.e, interfaceC0762c);
        f4.f553c = ((Boolean) obj).booleanValue();
        return f4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        Boolean bool = (Boolean) obj;
        bool.booleanValue();
        return ((F) create(bool, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v10 */
    /* JADX WARN: Type inference failed for: r0v2 */
    /* JADX WARN: Type inference failed for: r0v3 */
    /* JADX WARN: Type inference failed for: r0v5 */
    /* JADX WARN: Type inference failed for: r0v6 */
    /* JADX WARN: Type inference failed for: r0v9 */
    /* JADX WARN: Type inference failed for: r1v0, types: [int] */
    /* JADX WARN: Type inference failed for: r1v1, types: [boolean] */
    /* JADX WARN: Type inference failed for: r1v10 */
    /* JADX WARN: Type inference failed for: r1v13 */
    /* JADX WARN: Type inference failed for: r1v14 */
    /* JADX WARN: Type inference failed for: r1v15 */
    /* JADX WARN: Type inference failed for: r1v4, types: [boolean] */
    /* JADX WARN: Type inference failed for: r1v7 */
    /* JADX WARN: Type inference failed for: r5v0 */
    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Throwable th;
        int iIntValue;
        ?? r02;
        ?? r03;
        m0 m0Var;
        ?? r12;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        ?? r13 = this.f552b;
        Q q4 = this.f554d;
        try {
        } catch (Throwable th2) {
            if (r13 != 0) {
                l0 l0VarF = q4.f();
                this.f551a = th2;
                this.f553c = r13;
                this.f552b = 2;
                Integer numA = l0VarF.a();
                if (numA != enumC0789a) {
                    r03 = r13;
                    th = th2;
                    obj = numA;
                }
                return enumC0789a;
            }
            ?? r5 = r13;
            th = th2;
            iIntValue = this.e;
            r02 = r5 == true ? 1 : 0;
        }
        if (r13 == 0) {
            AbstractC0367g.M(obj);
            boolean z4 = this.f553c;
            this.f553c = z4;
            this.f552b = 1;
            obj = Q.e(q4, z4, this);
            r13 = z4;
            if (obj == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (r13 != 1) {
                if (r13 != 2) {
                    throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                }
                boolean z5 = this.f553c;
                th = this.f551a;
                AbstractC0367g.M(obj);
                r03 = z5;
                iIntValue = ((Number) obj).intValue();
                r02 = r03;
                e0 e0Var = new e0(iIntValue, th);
                r12 = r02;
                m0Var = e0Var;
                return new w3.c(m0Var, Boolean.valueOf((boolean) r12));
            }
            boolean z6 = this.f553c;
            AbstractC0367g.M(obj);
            r13 = z6;
        }
        m0Var = (m0) obj;
        r12 = r13;
        return new w3.c(m0Var, Boolean.valueOf((boolean) r12));
    }
}
