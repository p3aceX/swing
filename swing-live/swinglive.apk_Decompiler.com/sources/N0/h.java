package N0;

import M0.W;
import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import android.util.Base64;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class h extends A0.a {
    public static final Parcelable.Creator<h> CREATOR = new W(25);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final d f1122a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1123b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f1124c;

    public h(d dVar, String str, String str2) {
        F.g(dVar);
        this.f1122a = dVar;
        this.f1124c = str;
        this.f1123b = str2;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof h)) {
            return false;
        }
        h hVar = (h) obj;
        String str = this.f1124c;
        if (str == null) {
            if (hVar.f1124c != null) {
                return false;
            }
        } else if (!str.equals(hVar.f1124c)) {
            return false;
        }
        if (!this.f1122a.equals(hVar.f1122a)) {
            return false;
        }
        String str2 = hVar.f1123b;
        String str3 = this.f1123b;
        if (str3 == null) {
            if (str2 != null) {
                return false;
            }
        } else if (!str3.equals(str2)) {
            return false;
        }
        return true;
    }

    public final int hashCode() {
        String str = this.f1124c;
        int iHashCode = this.f1122a.hashCode() + (((str == null ? 0 : str.hashCode()) + 31) * 31);
        String str2 = this.f1123b;
        return (iHashCode * 31) + (str2 != null ? str2.hashCode() : 0);
    }

    public final String toString() {
        d dVar = this.f1122a;
        try {
            JSONObject jSONObject = new JSONObject();
            jSONObject.put("keyHandle", Base64.encodeToString(dVar.f1112b, 11));
            f fVar = dVar.f1113c;
            if (fVar != f.UNKNOWN) {
                jSONObject.put("version", fVar.f1117a);
            }
            ArrayList arrayList = dVar.f1114d;
            if (arrayList != null) {
                jSONObject.put("transports", arrayList.toString());
            }
            String str = this.f1124c;
            if (str != null) {
                jSONObject.put("challenge", str);
            }
            String str2 = this.f1123b;
            if (str2 != null) {
                jSONObject.put("appId", str2);
            }
            return jSONObject.toString();
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 2, this.f1122a, i4, false);
        AbstractC0184a.i0(parcel, 3, this.f1124c, false);
        AbstractC0184a.i0(parcel, 4, this.f1123b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
