const API_URL = `http://${window.location.hostname}:8000/api/members`;
let currentPage = 1;

async function fetchMembers(page) {
    const res = await fetch(`${API_URL}?page=${page}`);
    const data = await res.json();
    renderTable(data);
    renderPagination(data);
}

function renderTable(data) {
    document.getElementById('total-count').textContent =
        `(총 ${data.total.toLocaleString()}명)`;

    const tbody = document.getElementById('member-table');
    tbody.innerHTML = data.members.map(m => `
        <tr>
            <td>${m.uid}</td>
            <td>${m.user_id}</td>
            <td>${m.nickname}</td>
            <td>${m.email}</td>
            <td>${m.level}</td>
            <td>${m.point.toLocaleString()}</td>
            <td>${m.reg_date}</td>
        </tr>
    `).join('');
}

function renderPagination(data) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';

    for (let i = 1; i <= data.total_pages; i++) {
        const btn = document.createElement('button');
        btn.textContent = i;
        if (i === data.current_page) btn.classList.add('active');
        btn.addEventListener('click', () => {
            currentPage = i;
            fetchMembers(i);
        });
        pagination.appendChild(btn);
    }
}

fetchMembers(currentPage);
