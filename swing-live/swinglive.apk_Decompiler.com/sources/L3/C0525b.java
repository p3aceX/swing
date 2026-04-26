package l3;

import java.nio.ByteBuffer;
import java.util.List;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: l3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0525b extends O2.q {
    public static final C0525b e = new C0525b(0);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ int f5674d;

    public /* synthetic */ C0525b(int i4) {
        this.f5674d = i4;
    }

    @Override // O2.q
    public Object f(byte b5, ByteBuffer byteBuffer) {
        switch (this.f5674d) {
            case 1:
                J3.i.e(byteBuffer, "buffer");
                if (b5 == -127) {
                    Long l2 = (Long) e(byteBuffer);
                    if (l2 != null) {
                        int iLongValue = (int) l2.longValue();
                        M.f5665b.getClass();
                        M[] mArrValues = M.values();
                        int length = mArrValues.length;
                        for (int i4 = 0; i4 < length; i4++) {
                            M m4 = mArrValues[i4];
                            if (m4.f5669a == iLongValue) {
                            }
                        }
                    }
                } else if (b5 == -126) {
                    Object objE = e(byteBuffer);
                    List list = objE instanceof List ? (List) objE : null;
                    if (list != null) {
                        String str = (String) list.get(0);
                        Object obj = list.get(1);
                        J3.i.c(obj, "null cannot be cast to non-null type kotlin.Boolean");
                    }
                } else if (b5 == -125) {
                    Object objE2 = e(byteBuffer);
                    List list2 = objE2 instanceof List ? (List) objE2 : null;
                    if (list2 != null) {
                        String str2 = (String) list2.get(0);
                        Object obj2 = list2.get(1);
                        J3.i.c(obj2, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.StringListLookupResultType");
                    }
                }
                break;
        }
        return super.f(b5, byteBuffer);
    }

    @Override // O2.q
    public void k(F3.a aVar, Object obj) {
        switch (this.f5674d) {
            case 1:
                if (obj instanceof M) {
                    aVar.write(129);
                    k(aVar, Long.valueOf(((M) obj).f5669a));
                } else if (obj instanceof C0530g) {
                    aVar.write(130);
                    k(aVar, ((C0530g) obj).a());
                } else if (!(obj instanceof O)) {
                    super.k(aVar, obj);
                } else {
                    aVar.write(131);
                    O o4 = (O) obj;
                    k(aVar, AbstractC0729i.T(o4.f5670a, o4.f5671b));
                }
                break;
            default:
                super.k(aVar, obj);
                break;
        }
    }
}
