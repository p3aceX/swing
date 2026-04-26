package z3;

import A3.h;
import I3.p;
import J3.i;
import J3.u;
import e1.AbstractC0367g;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: z3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0790b extends h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f7001a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ p f7002b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ InterfaceC0762c f7003c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0790b(p pVar, InterfaceC0762c interfaceC0762c, InterfaceC0762c interfaceC0762c2) {
        super(interfaceC0762c);
        this.f7002b = pVar;
        this.f7003c = interfaceC0762c2;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        int i4 = this.f7001a;
        if (i4 != 0) {
            if (i4 != 1) {
                throw new IllegalStateException("This coroutine had already completed");
            }
            this.f7001a = 2;
            AbstractC0367g.M(obj);
            return obj;
        }
        this.f7001a = 1;
        AbstractC0367g.M(obj);
        p pVar = this.f7002b;
        i.c(pVar, "null cannot be cast to non-null type kotlin.Function2<R of kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsJvmKt.createCoroutineUnintercepted, kotlin.coroutines.Continuation<T of kotlin.coroutines.intrinsics.IntrinsicsKt__IntrinsicsJvmKt.createCoroutineUnintercepted>, kotlin.Any?>");
        u.a(2, pVar);
        return pVar.invoke(this.f7003c, this);
    }
}
