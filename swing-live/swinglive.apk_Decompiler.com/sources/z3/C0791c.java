package z3;

import I3.p;
import J3.i;
import J3.u;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: z3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0791c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f7004a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ p f7005b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ InterfaceC0762c f7006c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0791c(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h, p pVar, InterfaceC0762c interfaceC0762c2) {
        super(interfaceC0762c, interfaceC0767h);
        this.f7005b = pVar;
        this.f7006c = interfaceC0762c2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        int i4 = this.f7004a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("This coroutine had already completed");
            }
            this.f7004a = 2;
            AbstractC0367g.M(obj);
            return obj;
        }
        this.f7004a = 1;
        AbstractC0367g.M(obj);
        p pVar = this.f7005b;
        i.c(pVar, "null cannot be cast to non-null type kotlin.Function2<R of kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsJvmKt.createCoroutineUnintercepted, kotlin.coroutines.Continuation<T of kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsJvmKt.createCoroutineUnintercepted>, kotlin.Any?>");
        u.a(2, pVar);
        return pVar.invoke(this.f7006c, this);
    }
}
