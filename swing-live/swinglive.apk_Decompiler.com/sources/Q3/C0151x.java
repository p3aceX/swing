package Q3;

import y3.C0761b;
import y3.C0763d;
import y3.C0768i;
import y3.InterfaceC0764e;
import y3.InterfaceC0765f;
import y3.InterfaceC0767h;

/* JADX INFO: renamed from: Q3.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0151x implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1667a;

    public /* synthetic */ C0151x(int i4) {
        this.f1667a = i4;
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        C0761b c0761b;
        switch (this.f1667a) {
            case 0:
                Boolean bool = (Boolean) obj;
                bool.booleanValue();
                return bool;
            case 1:
                return ((InterfaceC0767h) obj).s((InterfaceC0765f) obj2);
            case 2:
                return ((InterfaceC0767h) obj).s((InterfaceC0765f) obj2);
            case 3:
                return Integer.valueOf(((Integer) obj).intValue() + 1);
            case 4:
                InterfaceC0765f interfaceC0765f = (InterfaceC0765f) obj2;
                if (!(interfaceC0765f instanceof A0)) {
                    return obj;
                }
                Integer num = obj instanceof Integer ? (Integer) obj : null;
                int iIntValue = num != null ? num.intValue() : 1;
                return iIntValue == 0 ? interfaceC0765f : Integer.valueOf(iIntValue + 1);
            case 5:
                A0 a02 = (A0) obj;
                InterfaceC0765f interfaceC0765f2 = (InterfaceC0765f) obj2;
                if (a02 != null) {
                    return a02;
                }
                if (interfaceC0765f2 instanceof A0) {
                    return (A0) interfaceC0765f2;
                }
                return null;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return (V3.w) obj;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                B1.b bVar = ((B1.d) obj).f116b;
                B1.b bVar2 = ((B1.d) obj2).f116b;
                long j4 = bVar.f110c;
                long j5 = bVar2.f110c;
                return Integer.valueOf(j4 < j5 ? -1 : j4 > j5 ? 1 : 0);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                B1.b bVar3 = ((B1.d) obj).f116b;
                B1.b bVar4 = ((B1.d) obj2).f116b;
                long j6 = bVar3.f110c;
                long j7 = bVar4.f110c;
                return Integer.valueOf(j6 < j7 ? -1 : j6 > j7 ? 1 : 0);
            case 9:
                String str = (String) obj;
                InterfaceC0765f interfaceC0765f3 = (InterfaceC0765f) obj2;
                J3.i.e(str, "acc");
                J3.i.e(interfaceC0765f3, "element");
                if (str.length() == 0) {
                    return interfaceC0765f3.toString();
                }
                return str + ", " + interfaceC0765f3;
            default:
                InterfaceC0767h interfaceC0767h = (InterfaceC0767h) obj;
                InterfaceC0765f interfaceC0765f4 = (InterfaceC0765f) obj2;
                J3.i.e(interfaceC0767h, "acc");
                J3.i.e(interfaceC0765f4, "element");
                InterfaceC0767h interfaceC0767hC = interfaceC0767h.c(interfaceC0765f4.getKey());
                C0768i c0768i = C0768i.f6945a;
                if (interfaceC0767hC == c0768i) {
                    return interfaceC0765f4;
                }
                C0763d c0763d = C0763d.f6944a;
                InterfaceC0764e interfaceC0764e = (InterfaceC0764e) interfaceC0767hC.i(c0763d);
                if (interfaceC0764e == null) {
                    c0761b = new C0761b(interfaceC0765f4, interfaceC0767hC);
                } else {
                    InterfaceC0767h interfaceC0767hC2 = interfaceC0767hC.c(c0763d);
                    if (interfaceC0767hC2 == c0768i) {
                        return new C0761b(interfaceC0764e, interfaceC0765f4);
                    }
                    c0761b = new C0761b(interfaceC0764e, new C0761b(interfaceC0765f4, interfaceC0767hC2));
                }
                return c0761b;
        }
    }
}
