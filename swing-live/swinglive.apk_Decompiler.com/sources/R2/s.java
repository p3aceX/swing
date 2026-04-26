package r2;

import e1.AbstractC0367g;
import java.util.List;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class s extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6399a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f6400b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ v f6401c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public s(v vVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6401c = vVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        s sVar = new s(this.f6401c, interfaceC0762c);
        sVar.f6400b = obj;
        return sVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((s) create((List) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        List list = (List) this.f6400b;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6399a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f6400b = null;
            this.f6399a = 1;
            if (this.f6401c.invoke(list, this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return w3.i.f6729a;
    }
}
