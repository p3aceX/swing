package I;

import e1.AbstractC0367g;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: renamed from: I.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0057s extends A3.j implements I3.q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f721a = 1;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f722b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f723c;

    public /* synthetic */ C0057s(int i4, InterfaceC0762c interfaceC0762c) {
        super(i4, interfaceC0762c);
    }

    @Override // I3.q
    public final Object b(Object obj, Object obj2, Object obj3) {
        switch (this.f721a) {
            case 0:
                return new C0057s((Q) this.f723c, (InterfaceC0762c) obj3).invokeSuspend(w3.i.f6729a);
            default:
                ((Boolean) obj2).getClass();
                C0057s c0057s = new C0057s(3, (InterfaceC0762c) obj3);
                c0057s.f723c = (T) obj;
                return c0057s.invokeSuspend(w3.i.f6729a);
        }
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws IllegalAccessException, IOException, InvocationTargetException {
        switch (this.f721a) {
            case 0:
                EnumC0789a enumC0789a = EnumC0789a.f6999a;
                int i4 = this.f722b;
                if (i4 == 0) {
                    AbstractC0367g.M(obj);
                    this.f722b = 1;
                    if (Q.a((Q) this.f723c, this) == enumC0789a) {
                        return enumC0789a;
                    }
                } else {
                    if (i4 != 1) {
                        throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                    }
                    AbstractC0367g.M(obj);
                }
                return w3.i.f6729a;
            default:
                EnumC0789a enumC0789a2 = EnumC0789a.f6999a;
                int i5 = this.f722b;
                if (i5 != 0) {
                    if (i5 != 1) {
                        throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
                    }
                    AbstractC0367g.M(obj);
                    return obj;
                }
                AbstractC0367g.M(obj);
                T t4 = (T) this.f723c;
                this.f722b = 1;
                t4.getClass();
                Object objA = T.a(t4, this);
                return objA == enumC0789a2 ? enumC0789a2 : objA;
        }
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0057s(Q q4, InterfaceC0762c interfaceC0762c) {
        super(3, interfaceC0762c);
        this.f723c = q4;
    }
}
