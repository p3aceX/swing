package l3;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class G extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f5645a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ K f5646b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f5647c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ String f5648d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public G(K k4, String str, String str2, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f5646b = k4;
        this.f5647c = str;
        this.f5648d = str2;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new G(this.f5646b, this.f5647c, this.f5648d, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((G) create((Q3.D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f5645a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            this.f5645a = 1;
            if (K.r(this.f5646b, this.f5647c, this.f5648d, this) == enumC0789a) {
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
