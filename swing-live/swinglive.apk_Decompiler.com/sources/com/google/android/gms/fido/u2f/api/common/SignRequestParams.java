package com.google.android.gms.fido.u2f.api.common;

import M0.W;
import N0.c;
import N0.h;
import a.AbstractC0184a;
import android.net.Uri;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public class SignRequestParams extends RequestParams {
    public static final Parcelable.Creator<SignRequestParams> CREATOR = new W(26);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Integer f3626a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Double f3627b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Uri f3628c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f3629d;
    public final ArrayList e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final c f3630f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final String f3631m;

    public SignRequestParams(Integer num, Double d5, Uri uri, byte[] bArr, ArrayList arrayList, c cVar, String str) {
        this.f3626a = num;
        this.f3627b = d5;
        this.f3628c = uri;
        this.f3629d = bArr;
        F.a("registeredKeys must not be null or empty", (arrayList == null || arrayList.isEmpty()) ? false : true);
        this.e = arrayList;
        this.f3630f = cVar;
        HashSet hashSet = new HashSet();
        if (uri != null) {
            hashSet.add(uri);
        }
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            h hVar = (h) it.next();
            F.a("registered key has null appId and no request appId is provided", (hVar.f1123b == null && uri == null) ? false : true);
            String str2 = hVar.f1123b;
            if (str2 != null) {
                hashSet.add(Uri.parse(str2));
            }
        }
        F.a("Display Hint cannot be longer than 80 characters", str == null || str.length() <= 80);
        this.f3631m = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof SignRequestParams)) {
            return false;
        }
        SignRequestParams signRequestParams = (SignRequestParams) obj;
        if (!F.j(this.f3626a, signRequestParams.f3626a) || !F.j(this.f3627b, signRequestParams.f3627b) || !F.j(this.f3628c, signRequestParams.f3628c) || !Arrays.equals(this.f3629d, signRequestParams.f3629d)) {
            return false;
        }
        ArrayList arrayList = this.e;
        ArrayList arrayList2 = signRequestParams.e;
        return arrayList.containsAll(arrayList2) && arrayList2.containsAll(arrayList) && F.j(this.f3630f, signRequestParams.f3630f) && F.j(this.f3631m, signRequestParams.f3631m);
    }

    public final int hashCode() {
        Integer numValueOf = Integer.valueOf(Arrays.hashCode(this.f3629d));
        return Arrays.hashCode(new Object[]{this.f3626a, this.f3628c, this.f3627b, this.e, this.f3630f, this.f3631m, numValueOf});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.f0(parcel, 2, this.f3626a);
        AbstractC0184a.d0(parcel, 3, this.f3627b);
        AbstractC0184a.h0(parcel, 4, this.f3628c, i4, false);
        AbstractC0184a.c0(parcel, 5, this.f3629d, false);
        AbstractC0184a.l0(parcel, 6, this.e, false);
        AbstractC0184a.h0(parcel, 7, this.f3630f, i4, false);
        AbstractC0184a.i0(parcel, 8, this.f3631m, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
