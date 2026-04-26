package T2;

import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import j3.C0468e;
import j3.C0472i;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class t implements J {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1997a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ ArrayList f1998b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ D2.v f1999c;

    public /* synthetic */ t(ArrayList arrayList, D2.v vVar, int i4) {
        this.f1997a = i4;
        this.f1998b = arrayList;
        this.f1999c = vVar;
    }

    @Override // T2.J
    public void a(v vVar) {
        switch (this.f1997a) {
            case 0:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case 1:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case 2:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case 3:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case 4:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case 5:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                this.f1999c.f(H0.a.k0(vVar));
                break;
            default:
                this.f1999c.f(H0.a.k0(vVar));
                break;
        }
    }

    public void b(C0468e c0468e) {
        switch (this.f1997a) {
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                this.f1999c.f(e1.k.H(c0468e));
                break;
            case 9:
                this.f1999c.f(e1.k.H(c0468e));
                break;
            case 10:
                this.f1999c.f(e1.k.H(c0468e));
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                this.f1999c.f(e1.k.H(c0468e));
                break;
            case 12:
                this.f1999c.f(e1.k.H(c0468e));
                break;
            default:
                this.f1999c.f(e1.k.H(c0468e));
                break;
        }
    }

    public void c() {
        switch (this.f1997a) {
            case 2:
                ArrayList arrayList = this.f1998b;
                arrayList.add(0, null);
                this.f1999c.f(arrayList);
                break;
            case 3:
                ArrayList arrayList2 = this.f1998b;
                arrayList2.add(0, null);
                this.f1999c.f(arrayList2);
                break;
            case 4:
                ArrayList arrayList3 = this.f1998b;
                arrayList3.add(0, null);
                this.f1999c.f(arrayList3);
                break;
            case 5:
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
            case 9:
            case 10:
            default:
                ArrayList arrayList4 = this.f1998b;
                arrayList4.add(0, null);
                this.f1999c.f(arrayList4);
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                ArrayList arrayList5 = this.f1998b;
                arrayList5.add(0, null);
                this.f1999c.f(arrayList5);
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                ArrayList arrayList6 = this.f1998b;
                arrayList6.add(0, null);
                this.f1999c.f(arrayList6);
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                ArrayList arrayList7 = this.f1998b;
                arrayList7.add(0, null);
                this.f1999c.f(arrayList7);
                break;
        }
    }

    public void d(Object obj) {
        switch (this.f1997a) {
            case 0:
                ArrayList arrayList = this.f1998b;
                arrayList.add(0, (Long) obj);
                this.f1999c.f(arrayList);
                break;
            case 1:
                ArrayList arrayList2 = this.f1998b;
                arrayList2.add(0, (String) obj);
                this.f1999c.f(arrayList2);
                break;
            case 2:
            case 3:
            case 4:
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
            default:
                ArrayList arrayList3 = this.f1998b;
                arrayList3.add(0, (Boolean) obj);
                this.f1999c.f(arrayList3);
                break;
            case 5:
                ArrayList arrayList4 = this.f1998b;
                arrayList4.add(0, (Double) obj);
                this.f1999c.f(arrayList4);
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                ArrayList arrayList5 = this.f1998b;
                arrayList5.add(0, (C0472i) obj);
                this.f1999c.f(arrayList5);
                break;
            case 9:
                ArrayList arrayList6 = this.f1998b;
                arrayList6.add(0, (C0472i) obj);
                this.f1999c.f(arrayList6);
                break;
            case 10:
                ArrayList arrayList7 = this.f1998b;
                arrayList7.add(0, (String) obj);
                this.f1999c.f(arrayList7);
                break;
        }
    }
}
