package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.p002firebaseauthapi.zzafm;
import j1.C0455E;
import j1.z;
import java.util.AbstractCollection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class e extends j1.l {
    public static final Parcelable.Creator<e> CREATOR = new C0511b(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public zzafm f5512a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public c f5513b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public String f5514c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public String f5515d;
    public ArrayList e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ArrayList f5516f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public String f5517m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public Boolean f5518n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public f f5519o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public boolean f5520p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public C0455E f5521q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public m f5522r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public AbstractCollection f5523s;

    public e(g1.f fVar, ArrayList arrayList) {
        fVar.a();
        this.f5514c = fVar.f4308b;
        this.f5515d = "com.google.firebase.auth.internal.DefaultFirebaseUser";
        this.f5517m = "2";
        d(arrayList);
    }

    @Override // j1.z
    public final String a() {
        return this.f5513b.f5506b;
    }

    @Override // j1.l
    public final String b() {
        Map map;
        zzafm zzafmVar = this.f5512a;
        if (zzafmVar == null || zzafmVar.zzc() == null || (map = (Map) ((Map) l.a(this.f5512a.zzc()).f104b).get("firebase")) == null) {
            return null;
        }
        return (String) map.get("tenant");
    }

    @Override // j1.l
    public final boolean c() {
        String str;
        Boolean bool = this.f5518n;
        if (bool == null || bool.booleanValue()) {
            zzafm zzafmVar = this.f5512a;
            if (zzafmVar != null) {
                Map map = (Map) ((Map) l.a(zzafmVar.zzc()).f104b).get("firebase");
                str = map != null ? (String) map.get("sign_in_provider") : null;
            } else {
                str = "";
            }
            boolean z4 = true;
            if (this.e.size() > 1 || (str != null && str.equals("custom"))) {
                z4 = false;
            }
            this.f5518n = Boolean.valueOf(z4);
        }
        return this.f5518n.booleanValue();
    }

    @Override // j1.l
    public final synchronized e d(ArrayList arrayList) {
        try {
            F.g(arrayList);
            this.e = new ArrayList(arrayList.size());
            this.f5516f = new ArrayList(arrayList.size());
            for (int i4 = 0; i4 < arrayList.size(); i4++) {
                z zVar = (z) arrayList.get(i4);
                if (zVar.a().equals("firebase")) {
                    this.f5513b = (c) zVar;
                } else {
                    this.f5516f.add(zVar.a());
                }
                this.e.add((c) zVar);
            }
            if (this.f5513b == null) {
                this.f5513b = (c) this.e.get(0);
            }
        } catch (Throwable th) {
            throw th;
        }
        return this;
    }

    @Override // j1.l
    public final void e(ArrayList arrayList) {
        m mVar;
        if (arrayList.isEmpty()) {
            mVar = null;
        } else {
            ArrayList arrayList2 = new ArrayList();
            ArrayList arrayList3 = new ArrayList();
            Iterator it = arrayList.iterator();
            while (it.hasNext()) {
                j1.p pVar = (j1.p) it.next();
                if (pVar instanceof j1.u) {
                    arrayList2.add((j1.u) pVar);
                } else if (pVar instanceof j1.x) {
                    arrayList3.add((j1.x) pVar);
                }
            }
            mVar = new m(arrayList2, arrayList3);
        }
        this.f5522r = mVar;
    }

    /* JADX WARN: Type inference failed for: r7v1, types: [java.util.AbstractCollection, java.util.List] */
    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f5512a, i4, false);
        AbstractC0184a.h0(parcel, 2, this.f5513b, i4, false);
        AbstractC0184a.i0(parcel, 3, this.f5514c, false);
        AbstractC0184a.i0(parcel, 4, this.f5515d, false);
        AbstractC0184a.l0(parcel, 5, this.e, false);
        AbstractC0184a.j0(parcel, 6, this.f5516f);
        AbstractC0184a.i0(parcel, 7, this.f5517m, false);
        boolean zC = c();
        AbstractC0184a.o0(parcel, 8, 4);
        parcel.writeInt(zC ? 1 : 0);
        AbstractC0184a.h0(parcel, 9, this.f5519o, i4, false);
        boolean z4 = this.f5520p;
        AbstractC0184a.o0(parcel, 10, 4);
        parcel.writeInt(z4 ? 1 : 0);
        AbstractC0184a.h0(parcel, 11, this.f5521q, i4, false);
        AbstractC0184a.h0(parcel, 12, this.f5522r, i4, false);
        AbstractC0184a.l0(parcel, 13, this.f5523s, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
