package com.google.android.gms.auth.api.signin;

import A0.a;
import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.ReflectedParcelable;
import java.util.ArrayList;
import java.util.HashSet;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import x0.e;

/* JADX INFO: loaded from: classes.dex */
public class GoogleSignInAccount extends a implements ReflectedParcelable {
    public static final Parcelable.Creator<GoogleSignInAccount> CREATOR = new e(0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3330a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f3331b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f3332c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f3333d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Uri f3334f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public String f3335m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final long f3336n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final String f3337o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final ArrayList f3338p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final String f3339q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final String f3340r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final HashSet f3341s = new HashSet();

    public GoogleSignInAccount(int i4, String str, String str2, String str3, String str4, Uri uri, String str5, long j4, String str6, ArrayList arrayList, String str7, String str8) {
        this.f3330a = i4;
        this.f3331b = str;
        this.f3332c = str2;
        this.f3333d = str3;
        this.e = str4;
        this.f3334f = uri;
        this.f3335m = str5;
        this.f3336n = j4;
        this.f3337o = str6;
        this.f3338p = arrayList;
        this.f3339q = str7;
        this.f3340r = str8;
    }

    public static GoogleSignInAccount b(String str) throws JSONException {
        if (TextUtils.isEmpty(str)) {
            return null;
        }
        JSONObject jSONObject = new JSONObject(str);
        String strOptString = jSONObject.optString("photoUrl");
        Uri uri = !TextUtils.isEmpty(strOptString) ? Uri.parse(strOptString) : null;
        long j4 = Long.parseLong(jSONObject.getString("expirationTime"));
        HashSet hashSet = new HashSet();
        JSONArray jSONArray = jSONObject.getJSONArray("grantedScopes");
        int length = jSONArray.length();
        for (int i4 = 0; i4 < length; i4++) {
            hashSet.add(new Scope(1, jSONArray.getString(i4)));
        }
        String strOptString2 = jSONObject.optString("id");
        String strOptString3 = jSONObject.has("tokenId") ? jSONObject.optString("tokenId") : null;
        String strOptString4 = jSONObject.has("email") ? jSONObject.optString("email") : null;
        String strOptString5 = jSONObject.has("displayName") ? jSONObject.optString("displayName") : null;
        String strOptString6 = jSONObject.has("givenName") ? jSONObject.optString("givenName") : null;
        String strOptString7 = jSONObject.has("familyName") ? jSONObject.optString("familyName") : null;
        String string = jSONObject.getString("obfuscatedIdentifier");
        F.d(string);
        GoogleSignInAccount googleSignInAccount = new GoogleSignInAccount(3, strOptString2, strOptString3, strOptString4, strOptString5, uri, null, j4, string, new ArrayList(hashSet), strOptString6, strOptString7);
        googleSignInAccount.f3335m = jSONObject.has("serverAuthCode") ? jSONObject.optString("serverAuthCode") : null;
        return googleSignInAccount;
    }

    public final boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof GoogleSignInAccount)) {
            return false;
        }
        GoogleSignInAccount googleSignInAccount = (GoogleSignInAccount) obj;
        if (!googleSignInAccount.f3337o.equals(this.f3337o)) {
            return false;
        }
        HashSet hashSet = new HashSet(googleSignInAccount.f3338p);
        hashSet.addAll(googleSignInAccount.f3341s);
        HashSet hashSet2 = new HashSet(this.f3338p);
        hashSet2.addAll(this.f3341s);
        return hashSet.equals(hashSet2);
    }

    public final int hashCode() {
        int iHashCode = (this.f3337o.hashCode() + 527) * 31;
        HashSet hashSet = new HashSet(this.f3338p);
        hashSet.addAll(this.f3341s);
        return hashSet.hashCode() + iHashCode;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f3330a);
        AbstractC0184a.i0(parcel, 2, this.f3331b, false);
        AbstractC0184a.i0(parcel, 3, this.f3332c, false);
        AbstractC0184a.i0(parcel, 4, this.f3333d, false);
        AbstractC0184a.i0(parcel, 5, this.e, false);
        AbstractC0184a.h0(parcel, 6, this.f3334f, i4, false);
        AbstractC0184a.i0(parcel, 7, this.f3335m, false);
        AbstractC0184a.o0(parcel, 8, 8);
        parcel.writeLong(this.f3336n);
        AbstractC0184a.i0(parcel, 9, this.f3337o, false);
        AbstractC0184a.l0(parcel, 10, this.f3338p, false);
        AbstractC0184a.i0(parcel, 11, this.f3339q, false);
        AbstractC0184a.i0(parcel, 12, this.f3340r, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
