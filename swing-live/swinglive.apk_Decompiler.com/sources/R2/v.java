package r2;

import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.List;
import k.C0502t;
import n2.C0560c;
import n2.EnumC0562e;
import p2.C0617a;
import x2.AbstractC0720a;
import x3.AbstractC0729i;
import x3.AbstractC0730j;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class v extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f6411a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long f6412b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6413c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public /* synthetic */ Object f6414d;
    public final /* synthetic */ x e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ int f6415f;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public v(x xVar, int i4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.e = xVar;
        this.f6415f = i4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        v vVar = new v(this.e, this.f6415f, interfaceC0762c);
        vVar.f6414d = obj;
        return vVar;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((v) create((List) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        boolean z4;
        ArrayList arrayList;
        long j4;
        List list = (List) this.f6414d;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6413c;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            z4 = ((C0560c) list.get(0)).f5872c;
            x xVar = this.e;
            p2.b bVar = xVar.f6424l;
            C0502t c0502t = xVar.f6425m;
            int i5 = this.f6415f;
            bVar.getClass();
            J3.i.e(c0502t, "mpegTsPacketizer");
            C0617a c0617a = bVar.f6194a.e;
            if (c0617a == null) {
                arrayList = new ArrayList();
            } else {
                ArrayList arrayList2 = new ArrayList();
                if (bVar.f6196c >= 40 || z4) {
                    arrayList2.addAll(AbstractC0729i.T(bVar.e, c0617a));
                    bVar.f6196c = 0;
                }
                if (bVar.f6195b >= 200) {
                    arrayList2.add(bVar.f6197d);
                    bVar.f6195b = 0;
                }
                bVar.f6195b++;
                bVar.f6196c++;
                ArrayList<byte[]> arrayListA = AbstractC0720a.a(i5, c0502t.f(arrayList2, true));
                ArrayList arrayList3 = new ArrayList(AbstractC0730j.V(arrayListA));
                for (byte[] bArr : arrayListA) {
                    EnumC0562e enumC0562e = EnumC0562e.f5877c;
                    w2.b bVar2 = w2.b.f6713b;
                    arrayList3.add(new C0560c(bArr, enumC0562e, false));
                }
                arrayList = arrayList3;
            }
            x xVar2 = this.e;
            EnumC0562e enumC0562e2 = EnumC0562e.f5877c;
            this.f6414d = list;
            this.f6411a = z4;
            this.f6413c = 1;
            obj = xVar2.g(arrayList, enumC0562e2, this);
            if (obj != enumC0789a) {
            }
            return enumC0789a;
        }
        if (i4 != 1) {
            if (i4 != 2) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            j4 = this.f6412b;
            AbstractC0367g.M(obj);
            long jLongValue = ((Number) obj).longValue();
            this.e.getClass();
            this.e.f83i += j4 + jLongValue;
            return w3.i.f6729a;
        }
        z4 = this.f6411a;
        AbstractC0367g.M(obj);
        long jLongValue2 = ((Number) obj).longValue();
        x xVar3 = this.e;
        EnumC0562e enumC0562e3 = ((C0560c) list.get(0)).f5871b;
        this.f6414d = null;
        this.f6411a = z4;
        this.f6412b = jLongValue2;
        this.f6413c = 2;
        obj = xVar3.g(list, enumC0562e3, this);
        if (obj != enumC0789a) {
            j4 = jLongValue2;
            long jLongValue3 = ((Number) obj).longValue();
            this.e.getClass();
            this.e.f83i += j4 + jLongValue3;
            return w3.i.f6729a;
        }
        return enumC0789a;
    }
}
