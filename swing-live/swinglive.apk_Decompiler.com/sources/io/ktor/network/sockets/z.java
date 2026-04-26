package io.ktor.network.sockets;

import e1.AbstractC0367g;
import io.ktor.utils.io.J;
import io.ktor.utils.io.L;
import java.lang.reflect.InvocationTargetException;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class z extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4942a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ A f4943b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public z(A a5, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f4943b = a5;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new z(this.f4943b, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((z) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws IllegalAccessException, InvocationTargetException {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f4942a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            J j4 = (J) this.f4943b.readerJob;
            if (j4 != null) {
                this.f4942a = 1;
                if (j4.b(this) == enumC0789a) {
                    return enumC0789a;
                }
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        L l2 = (L) this.f4943b.writerJob;
        if (l2 != null) {
            io.ktor.utils.io.z.a(l2);
        }
        this.f4943b.i();
        return w3.i.f6729a;
    }
}
